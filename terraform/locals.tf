locals {
  s3_bucket_name = "pearlbucket00"
  ecr_repo_name  = "pearl-ecr-repo"

  ecs_cluster_name             = "pearlcluster00"
  ecs_task_family              = "pearlfamily"
  ecs_task_name                = "pearltask"
  ecs_host_port                = 3000
  ecs_container_port           = 3000
  ecs_task_execution_role_name = "ecsTaskExecutionRole"

  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  target_group_name              = "node-app-tg"
  application_load_balancer_name = "node-app-alb"

  ecs_service_name = "pearlecsservice00"
}
