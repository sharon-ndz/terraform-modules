# VPC ID
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

# VPC ID
output "public_subnets_ids" {
  description = "public subnets ids"
  value       = aws_subnet.public_subnets.*.id
}