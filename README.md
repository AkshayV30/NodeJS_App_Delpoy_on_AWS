# Pearl Node Service

A compact Node.js 20 and Express 5 service for learning service design, containerization, and AWS delivery. It serves a small status page and JSON endpoints, and includes a Docker image, Terraform infrastructure, and a GitHub Actions deployment workflow.

## Get started

Requirements: Node.js 20 or newer and npm.

```sh
npm ci
npm test
npm run dev
```

Open <http://localhost:3000>. `npm run dev` restarts the service when source files change. Use `npm start` for a normal local run.

## Endpoints

| Path | Purpose |
| --- | --- |
| `/` | Demo page with live service and runtime details |
| `/api/v1/info` | Service version, runtime, framework, platform, start time, and uptime |
| `/health/live` | Confirms the process is responding |
| `/health/ready` | Readiness endpoint used by the container, ECS, and load balancer |

The health check reports process availability only. There are no external application dependencies to probe in this demo.

## Run with Docker

```sh
docker build -t pearl-node-service .
docker run --rm -p 3000:3000 pearl-node-service
```

For a development container with source reload, use `docker compose up --build`.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3000` | HTTP listener port |
| `NODE_ENV` | `development` | Runtime environment label |
| `APP_VERSION` | Package version | Version returned by `/api/v1/info` |
| `APP_PLATFORM` | Detected runtime | Platform label shown by the service |
| `HEALTH_CHECK_URL` | `http://127.0.0.1:<PORT>/health/ready` | Optional health-check target override |
| `TRUST_PROXY` | `false` | Set to `true` only behind one trusted proxy hop |

## Deploy to AWS

Terraform and GitHub Actions deployment instructions are in [AWS deployment](docs/aws-deployment.md). The deployment uses ECR, ECS Fargate, an Application Load Balancer, and GitHub OIDC. Terraform provisioning is a separate, reviewed operation.

## Design documentation

- [Architecture](docs/architecture.md): AWS components and deployment flow.
- [System design](docs/system-design.md): application modules, request flow, health behavior, and operational decisions.
- [AWS deployment](docs/aws-deployment.md): prerequisites, Terraform bootstrap, initial image, and CI/CD configuration.

## Limitations

This is a deployment demo, not a ready-made production service. It has no database or persistent application data. The sample Terraform configuration uses public subnets and an HTTP load balancer; review networking, TLS, IAM, state storage, and costs before adapting it for a real workload.
