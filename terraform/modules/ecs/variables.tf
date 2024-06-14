
variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS Cluster service name"
  type        = string
}

variable "task_family" {
  description = "Name of the ECS Cluster :Task family"
  type        = string
}
variable "container_port" {
  description = "Container port Number"
  type        = number
  default     = 3000
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

variable "ecr_repo_url" {
  type = string
}
