resource "aws_ecs_cluster" "demo_app_cluster" {
  name = var.demo_app_cluster_name

  #   setting {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
}
# -------------------------------------------------------vpc----------------------------
resource "aws_default_vpc" "default_vpc" {

  cidr_block = "10.0.0.0/16"
  #   tags = {
  #     Name = "Default VPC"
  #   }
}
# -------------------------------------------------------subnet----------------------------
resource "aws_default_subnet" "default_az1" {
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Default subnet for us-east-2a"
  }
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Default subnet for us-east-2b"
  }
}
resource "aws_default_subnet" "default_az3" {
  availability_zone = var.availability_zones[2]

  tags = {
    Name = "Default subnet for us-east-2b"
  }
}

# -------------------------------------------------------ECS task Defination---------------------------
resource "aws_ecs_task_definition" "demo_app_task" {
  family                   = var.demo_app_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  # cpu                      = 256 #0.25 vCPU
  # memory                   = 512 #0.5GB(512 MiB)
  # execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name" : "${var.demo_app_task_name}",
      "image" : "${var.ecr_repo_url}",
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

# ----------------------aws-iam role-----

# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = var.ecs_task_execution_role_name

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json


#   # tags = {
#   #   tag-key = "tag-value"
#   # }
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }


# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# -----------------------aws application load balancer-------------------
resource "aws_lb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"
  # subnets            = [for subnet in aws_subnet.public : subnet.id]
  subnets = [
    "${aws_default_subnet.default_az1.id}",
    "${aws_default_subnet.default_az2.id}",
  "${aws_default_subnet.default_az3.id}"]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]

  # tags = {
  #   Environment = "production"
  # }
}

# -----------------aws security group-----------------
resource "aws_security_group" "load_balancer_security_group" {

  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow public access for now (consider restricting later)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------ IP Target Group-----------
resource "aws_lb_target_group" "target-group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

# -------------------lb listener-   Forward Action-------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# ------------------------aws ecs service-----
resource "aws_ecs_service" "demo_app_service" {
  name            = var.demo_app_service_name
  cluster         = aws_ecs_cluster.demo_app_cluster.id
  task_definition = aws_ecs_task_definition.demo_app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = aws_ecs_task_definition.demo_app_task.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets = [
      aws_default_subnet.default_az1.id,
      aws_default_subnet.default_az2.id,
      aws_default_subnet.default_az3.id
    ]
    assign_public_ip = true
    security_groups  = [aws_security_group_service_security_group.id]
  }

}

# ---------------security group 2
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
