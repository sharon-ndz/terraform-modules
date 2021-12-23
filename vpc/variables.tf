 ###General###
variable "environment" {}
variable "region" {
  default = ""
}
variable "common_tags" {
  type = map
}

###VPC###
variable "instance_tenancy" {
  type = string
  default = "default"
}
variable "enable_dns_support" {
  type = bool
}
variable "enable_dns_hostnames" {
  type = bool
}
variable "vpc_name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}

###IGW###
variable "internet_gateway_name" {
  type = string
}

###NGW###
variable "total_nat_gateway_required" {
  type = number
}
variable "eip_for_nat_gateway_name" {
  type = string
}
variable "nat_gateway_name" {
  type = string
}

###Private LB Subnets###
variable "private_lb_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
}

###Private App Subnets###
variable "private_app_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
}

##Private Data Subnets
variable "private_data_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
    is_public                = bool
  })
}

##Private Services Subnets
variable "private_services_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
}

###Public Subnets###
variable "public_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    map_public_ip_on_launch  = bool
    route_table_name         = string
  })
}

##Flow Logs###
variable "vpc_flow_logs" {
  type = object({
    bucket_arn                = string
    log_destination_type      = string
    traffic_type              = string
    max_aggregation_interval  = string
    name_prefix               = string
  })
  description = "vpc flow logs related variables"
}

variable "s3_endpoint_name_prefix" {
  type = string
  description = "name of the s3 vpc endpoint"
}