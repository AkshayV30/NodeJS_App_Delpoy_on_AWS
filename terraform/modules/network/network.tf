# # # -------------------------------------------------------vpc----------------------------
resource "aws_default_vpc" "vpc" {

  #   cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Default VPC"
  }
}

# # #  -------------------------------------------------------subnet----------------------------
resource "aws_default_subnet" "az1" {
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Default subnet for ${var.availability_zones[0]}"
  }
}
resource "aws_default_subnet" "az2" {
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Default subnet for ${var.availability_zones[1]}"
  }
}
resource "aws_default_subnet" "az3" {
  availability_zone = var.availability_zones[2]

  tags = {
    Name = "Default subnet for ${var.availability_zones[2]}"
  }
}

# # # -----------------------security group-------------------

resource "aws_security_group" "load_balancer_security_group" {

  vpc_id = aws_default_vpc.vpc.id

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

# # ---------------security group 2
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_default_vpc.vpc.id

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
