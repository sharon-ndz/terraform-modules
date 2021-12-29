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

# Public Subnets CIDRs
output "public_subnets_cidrs" {
  description = "public subnets cidrs"
  value       = aws_subnet.public_subnets.*.cidr_block
}

# LB Subnets CIDRs
output "lb_subnets_cidrs" {
  description = "lb subnets cidrs"
  value       = aws_subnet.private_lb_subnets.*.cidr_block
}

# App Subnets CIDRs
output "app_subnets_cidrs" {
  description = "app subnets cidrs"
  value       = aws_subnet.private_app_subnets.*.cidr_block
}

# Data Subnets CIDRs
output "data_subnets_cidrs" {
  description = "data subnets cidrs"
  value       = aws_subnet.private_data_subnets.*.cidr_block
}

# Services Subnets CIDRs
output "services_subnets_cidrs" {
  description = "services subnets cidrs"
  value       = aws_subnet.private_services_subnets.*.cidr_block
}