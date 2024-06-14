terraform {
  backend "s3" {
    bucket = "pearlbucket00"
    key    = "pearlbucket00/terraform.tfstate"
    region = "us-east-2"
    # encrypt = true
  }

}

