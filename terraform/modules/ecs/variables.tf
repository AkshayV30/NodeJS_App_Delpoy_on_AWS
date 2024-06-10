variable "target_group_name" {
  description = "Target Group Name"
  type        = string
}

variable "container_port" {
  description = "Container port number"
  type        = number
}

variable "demo_app_service_name" {
  description = "Demo App Service Name"
  type        = string
}

variable "demo_app_cluster_name" {
  description = "ECS cluster Name"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "demo_app_task_family" {
  description = "ECS Task Family"
  type        = string
}

variable "demo_app_task_name" {
  description = "Demo app Task Name"
  type        = string
}

variable "host_port" {
  description = "Host port number"
  type        = number
}

variable "ecr_repo_url" {
  description = "ECR Repo URL"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
}

variable "application_load_balancer_name" {
  description = "Application Load Balancer Name"
  type        = string
}
