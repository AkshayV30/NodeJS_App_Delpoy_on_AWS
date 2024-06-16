variable "container_port" {
  description = "Container port"
  type        = number
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
}

variable "application_load_balancer_name" {
  description = "Application load balancer name"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
