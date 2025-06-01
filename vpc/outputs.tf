# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "default_security_group_id" {
  description = "The default security group ID of the VPC"
  value       = aws_vpc.vpc.default_security_group_id
}

# Public Subnets IDs
output "public_subnets_ids" {
  description = "public subnets ids"
  value       = aws_subnet.public_subnets.*.id
}


#Public Subnets CIDRs
output "public_subnets_cidrs" {
  description = "public subnets cidrs"
  value       = aws_subnet.public_subnets.*.cidr_block
}

# Private Subnets IDs
output "private_subnets_ids" {
  description = "private subnets ids"
  value       = aws_subnet.private_subnets.*.id
}


#private Subnets CIDRs
output "private_subnets_cidrs" {
  description = "private subnets cidrs"
  value       = aws_subnet.private_subnets.*.cidr_block
}


