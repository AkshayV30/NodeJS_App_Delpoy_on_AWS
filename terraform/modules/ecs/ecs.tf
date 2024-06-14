resource "aws_ecs_cluster" "node_app_cluster" {
  name = var.cluster_name

  #   setting {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
}

# # # -------------------------------------------------------ECS task Defination---------------------------
resource "aws_ecs_task_definition" "node_app_task" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 #0.25 vCPU
  memory                   = 512 #0.5GB(512 MiB)
  # execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.task_name,
      image     = var.ecr_repo_url,
      cpu       = 256 #0.25 vCPU
      memory    = 512 #0.5GB(512 MiB)
      essential = true
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.host_port
        }
      ]
    },

  ])


  #   runtime_platform {
  #     operating_system_family = "WINDOWS_SERVER_2019_CORE"
  #     cpu_architecture        = "X86_64"
  #   }
}

# # # ------------------------aws ecs service-----
resource "aws_ecs_service" "node_app_service" {
  name             = var.service_name
  cluster          = aws_ecs_cluster.node_app_cluster.id
  task_definition  = aws_ecs_task_definition.node_app_task.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 2

  load_balancer {
    target_group_arn = module.app_load_balancer.target_group.arn
    #  container_name   = aws_ecs_task_definition.node_app_task.family
    container_name = var.task_name
    container_port = var.container_port
  }

  network_configuration {
    subnets = [
      module.network.az1.id,
      module.network.az2.id,
      module.network.az3.id,

    ]
    assign_public_ip = true
    #  security_groups  = [aws_security_group.service_security_group.id]
    security_groups = [module.network.service_security_group.id]
  }

}


