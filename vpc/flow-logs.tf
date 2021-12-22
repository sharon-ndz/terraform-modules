resource "aws_flow_log" "flow_logs" {
  log_destination          = lookup(var.vpc_flow_logs, "bucket_arn", null)
  log_destination_type     = lookup(var.vpc_flow_logs, "log_destination_type", null)
  traffic_type             = lookup(var.vpc_flow_logs, "traffic_type", null)
  vpc_id                   = aws_vpc.vpc.id
  max_aggregation_interval = lookup(var.vpc_flow_logs, "max_aggregation_interval", null)
  tags                     = merge({ Name = format("%s-vpc-flowlogs", lookup(var.vpc_flow_logs, "name_prefix", "")) }, var.common_tags)
}