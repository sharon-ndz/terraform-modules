###############################
## Terraform Resources ##
## VPC Endpoint for s3 that includes all route tables
###############################
resource "aws_vpc_endpoint" "vpc_s3_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = format("com.amazonaws.%s.s3", data.aws_region.current.name)
  route_table_ids = concat([aws_route_table.public_routes.id], aws_route_table.private_app_subnets_rt[*].id, aws_route_table.private_data_subnets_rt[*].id, aws_route_table.private_services_subnets_rt[*].id)
  tags            = merge({ Name = format("%s-s3-vpc-endpoint", var.s3_endpoint_name_prefix) }, var.common_tags)
}