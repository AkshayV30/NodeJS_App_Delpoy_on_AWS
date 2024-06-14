
# # -----------------------aws application load balancer-------------------
resource "aws_lb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"

  #   subnets         = ["${aws_default_subnet.az1.id}", "${aws_default_subnet.az2.id}", "${aws_default_subnet.az3.id}"]
  #   security_groups = ["${aws_security_group.load_balancer_security_group.id}"]

  subnets         = [module.network.az1.id, module.network.az2.id, module.network.az3.id]
  security_groups = [aws_security_group.load_balancer_security_group.id]

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
  vpc_id      = aws_default_vpc.vpc.id
}

# -------------------lb listener-   Forward Action-------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn

  }
}
