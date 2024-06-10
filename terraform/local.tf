locals {

  ecr_repo_name                  = "demo-app-ecr-repo"

  demo_app_cluster_name          = "demo-app-cluster"
  availability_zones             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  demo_app_task_family           = "demo_app_task"
  demo_app_task_name             = "demo_app_task"
  ecs_task_execution_role_name   = "demo-app-task_execution_role"
  application_load_balancer_name = "cc-demo-app-alb"
  target_group_name              = "cc-demo-alb-tg"
  demo_app_service_name          = "cc-demo-app-service"
  host_port                      = 3000
  container_port                 = 3000
}
