# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

# Public Subnets IDs
output "public_subnets_ids" {
  description = "public subnets ids"
  value       = aws_subnet.public_subnets.*.id
}

# LB Subnets IDs
output "lb_subnets_ids" {
  description = "lb subnets ids"
  value       = aws_subnet.private_lb_subnets.*.id
}

# App Subnets IDs
output "app_subnets_ids" {
  description = "app subnets ids"
  value       = aws_subnet.private_app_subnets.*.id
}

# Data Subnets IDs
output "data_subnets_ids" {
  description = "data subnets ids"
  value       = aws_subnet.private_data_subnets.*.id
}

# Services Subnets IDs
output "services_subnets_ids" {
  description = "services subnets ids"
  value       = aws_subnet.private_services_subnets.*.id
}