
variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR repository URL"
  type        = string
  # default     = "${docker_uri}var037983576349.dkr.ecr.us-east-2.amazonaws.com/pearl-ecr-repo:latest"
}


variable "task_family" {
  description = "Name of the ECS Cluster :Task family"
  type        = string
}
variable "container_port" {
  description = "Container port Number"
  type        = number
  # default     = 3000
}

variable "host_port" {
  description = "Host port Number"
  type        = number
  #   default     = 80
}

variable "task_name" {
  description = "ECS Task Name"
  type        = string
}



variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
  default     = "ecsTaskExecutionRole"
}


variable "service_name" {
  description = "Name of the ECS Cluster service name"
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

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}
