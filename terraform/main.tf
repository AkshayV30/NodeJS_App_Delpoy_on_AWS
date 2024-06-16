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


module "network" {
  source             = "./modules/network"
  availability_zones = local.availability_zones

}


module "appLoadBalancer" {

  source = "./modules/lb"

  container_port                 = local.ecs_container_port
  target_group_name              = local.target_group_name
  application_load_balancer_name = local.application_load_balancer_name


  subnets         = module.network.subnet_ids
  security_groups = [module.network.load_balancer_security_group_id]
  vpc_id          = module.network.vpc_id

}



module "ecsCluster" {
  source = "./modules/ecs"

  cluster_name = local.ecs_cluster_name

  task_family    = local.ecs_task_family
  task_name      = local.ecs_task_name
  host_port      = local.ecs_host_port
  container_port = local.ecs_container_port

  ecr_repo_url = "${var.docker_ecr_uri}${local.ecr_repo_name}:latest"

  ecs_task_execution_role_name = local.ecs_task_execution_role_name
  service_name                 = local.ecs_service_name


  subnets          = module.network.subnet_ids
  security_groups  = [module.network.service_security_group_id]
  target_group_arn = module.appLoadBalancer.target_group_arn

}



