locals {
  s3_bucket_name = "pearlbucket00"
  ecr_repo_name  = "pearl-ecr-repo"

  ecs_cluster_name = "pearlcluster00"
  ecs_service_name = "pearlecsservice00"
  ecs_task_family  = "pearlfamily"
  ecs_task_name    = "pearltask"
  host_port        = 3000
  container_port   = 3000

  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  target_group_name              = "node-app-tg"
  application_load_balancer_name = "node-app-alb"
}
