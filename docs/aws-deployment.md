# AWS deployment

This guide describes the checked-in Terraform and GitHub Actions workflow. Terraform creates infrastructure; GitHub Actions only tests, builds, publishes, and deploys application images after that infrastructure and the OIDC role exist.

## Prerequisites

- AWS CLI configured for the target account, Docker, and Terraform.
- Permission to create ECR, S3, IAM, security groups, an Application Load Balancer, and ECS resources.
- The S3 bucket configured in `terraform/backend.tf` (`pearlbucket00`, `us-east-2`) must already exist before initialization. Update the backend configuration if using another bucket.

Confirm the AWS account before applying changes:

```sh
aws sts get-caller-identity
```

Terraform is configured for `us-east-2`. Review `terraform/` before applying because the demo uses the default VPC, public subnets, public task IPs, and an HTTP load balancer.

## Bootstrap Terraform and ECR

From the repository root:

```sh
cd terraform
terraform init
terraform validate
```

Get the ECR registry URI and create the ECR repository first. Terraform builds the initial ECS task definition using the `latest` image reference, so this bootstrap lets the first task start after the initial image is pushed.

```sh
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-2.amazonaws.com"
terraform apply -target=module.ecrRepo -var="docker_ecr_uri=${ECR_REGISTRY}/"
```

Review the targeted Terraform plan before approving the apply. The trailing slash is used when Terraform assembles the ECR image URI.

## Push the initial image

From the repository root, authenticate and publish the `latest` image that the initial Terraform task definition references:

```sh
cd ..
aws ecr get-login-password --region us-east-2 \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"
docker build -t pearl-ecr-repo:latest .
docker tag pearl-ecr-repo:latest "$ECR_REGISTRY/pearl-ecr-repo:latest"
docker push "$ECR_REGISTRY/pearl-ecr-repo:latest"
```

## Plan and apply infrastructure

```sh
cd terraform
terraform plan -var="docker_ecr_uri=${ECR_REGISTRY}/" -out=terraform.tfplan
terraform apply terraform.tfplan
```

Review the saved plan before applying. Terraform creates the ECR repository, application S3 bucket, network security groups, Application Load Balancer, ECS cluster/task/service, and related roles. The state backend bucket is separate and must already exist.

Get the application URL and check readiness:

```sh
terraform output -raw application_url
curl "$(terraform output -raw application_url)/health/ready"
```

## Configure GitHub Actions deployment

The workflow is `.github/workflows/deploy-ecs.yaml`. It runs tests on pull requests to `master`. A push to `master` triggers tests and deployment; manual dispatch deploys only when run on `main` or `master`. The deploy job assumes the configured AWS role with GitHub OIDC, publishes an image tagged `<commit-sha>-<run-id>-<run-attempt>`, registers a new task definition with that image, updates the ECS service, and waits for stability. It does not apply Terraform.

Add these as secrets to the GitHub `production` environment:

| Secret | Value |
| --- | --- |
| `AWS_REGION` | AWS region containing ECR and ECS (`us-east-2` for this Terraform setup) |
| `AWS_ACCOUNT_ID` | 12-digit target AWS account ID |
| `AWS_ROLE_ARN` | IAM role trusted for this GitHub repository/environment through OIDC |
| `ECR_REPOSITORY_NAME` | ECR repository name (`pearl-ecr-repo` by default) |
| `ECS_CLUSTER` | ECS cluster name (`pearlcluster00` by default) |
| `ECS_SERVICE` | ECS service name (`pearlecsservice00` by default) |
| `ECS_TASK_DEFINITION` | Task definition family or ARN (`pearlfamily` by default) |
| `ECS_CONTAINER_NAME` | Container name in the task definition (`pearltask` by default) |

Restrict the role trust policy to this repository and intended branch/environment. Grant only the ECR push, ECS task-definition/service, task-definition read, and scoped `iam:PassRole` permissions needed by the workflow. Do not put AWS access keys in GitHub secrets; the workflow uses OIDC role assumption.

## Operational and cost notes

The ALB uses HTTP on port `3000`; configure TLS and a production network design before exposing a real service. Review IAM, security group ingress, state bucket ownership/versioning/encryption, naming, public IP assignment, and AWS costs. Destroy demo resources when no longer needed, after preserving any Terraform state required for future management.
