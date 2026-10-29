output "application_url" {
  description = "HTTP URL for the deployed application load balancer"
  value       = "http://${module.appLoadBalancer.dns_name}:3000"
}
