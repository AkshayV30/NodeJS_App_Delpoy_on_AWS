output "subnet_ids" {
  value = [
    aws_default_subnet.az1.id,
    aws_default_subnet.az2.id,
    aws_default_subnet.az3.id
  ]
}


output "load_balancer_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

output "service_security_group_id" {
  value = aws_security_group.service_security_group.id
}
output "vpc_id" {
  value = aws_default_vpc.vpc.id
}
