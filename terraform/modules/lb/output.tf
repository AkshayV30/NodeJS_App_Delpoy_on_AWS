output "target_group_arn" {
  value = aws_lb_target_group.target-group.arn
}

output "dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.application_load_balancer.dns_name
}
