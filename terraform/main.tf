terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}
# for stroign state file on s3 bucket
# module "tf-state"{
#    source="./modules/tf-state"
# }

module "ecrRepo" {
  source = "./modules/ecr"

  ecr_repo_name = local.ecr_repo_name
}

module "ecsCluster" {
  source = "./modules/ecs"

  ecr_repo_url                   = module.ecrRepo.repository_url
  demo_app_cluster_name          = local.demo_app_cluster_name
  availability_zones             = local.availability_zones
  demo_app_task_family           = local.demo_app_task_family
  demo_app_task_name             = local.demo_app_task_name
  host_port                      = local.host_port
  container_port                 = local.container_port
  ecs_task_execution_role_name   = local.ecs_task_execution_role_name
  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name
  demo_app_service_name          = local.demo_app_service_name


}
