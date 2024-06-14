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
