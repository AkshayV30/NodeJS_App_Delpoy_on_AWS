

resource "aws_ecs_cluster" "node_app_cluster" {
  name = var.cluster_name

  #   setting {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
}


# # # # -------------------------------------------------------ECS task Defination---------------------------
resource "aws_ecs_task_definition" "node_app_task" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 #0.25 vCPU
  memory                   = 512 #0.5GB(512 MiB)
  # execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = data.aws_iam_role.existing_ecs_task_execution_role.arn

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
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ]
    },

  ])


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


# # # -------------------iam roles-------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
    target_group_arn = var.target_group_arn
    # target_group_arn = module.app_load_balancer.target_group.arn

    container_name = var.task_name
    container_port = var.container_port
  }

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    #  security_groups  = [aws_security_group.service_security_group.id]
    security_groups = var.security_groups
  }

}


