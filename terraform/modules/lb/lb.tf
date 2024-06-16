
# # -----------------------aws application load balancer-------------------
resource "aws_lb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"

  subnets         = var.subnets
  security_groups = var.security_groups

  # tags = {
  #   Environment = "production"
  # }
}


# ------------------ IP Target Group-----------
resource "aws_lb_target_group" "target-group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

# -------------------lb listener-   Forward Action-------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn

  }
}
