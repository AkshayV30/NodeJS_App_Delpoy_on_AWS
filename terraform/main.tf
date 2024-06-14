terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }
  }


}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}


module "s3Bucket" {
  source      = "./modules/s3"
  bucket_name = local.s3_bucket_name
}


module "ecrRepo" {
  source    = "./modules/ecr"
  repo_name = local.ecr_repo_name
  ecr_uri   = var.docker_ecr_uri
}

module "ecsCluster" {
  source = "./modules/ecs"

  cluster_name = local.ecs_cluster_name

  task_family  = local.ecs_task_family
  service_name = local.ecs_service_name
  task_name    = local.ecs_task_name
  host_port    = local.host_port

  ecr_repo_url = module.ecrRepo.ecr_repo_url



}

module "network" {
  source             = "./modules/network"
  availability_zones = local.availability_zones

}


module "appLoadBalancer" {

  source = "./modules/lb"

  container_port                 = local.container_port
  target_group_name              = local.target_group_name
  application_load_balancer_name = local.application_load_balancer_name



}
