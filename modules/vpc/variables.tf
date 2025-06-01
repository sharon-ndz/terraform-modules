variable "environment" {
  description = "Environment for deployment"
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_tenancy" {
  description = "VPC instance tenancy"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support for VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "internet_gateway_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "total_nat_gateway_required" {
  description = "Number of NAT Gateways required"
  type        = number
}

variable "eip_for_nat_gateway_name" {
  description = "Name prefix for NAT Gateway Elastic IPs"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name prefix for NAT Gateways"
  type        = string
}

#variable "private_lb_subnets" {
#  type = object({
#    routes                   = list(any)
#    cidrs_blocks             = list(string)
#    subnets_name_prefix      = string
#    route_table_name         = string
#  })
#}

###Private App Subnets###
variable "private_subnets" {
  type = object({
    routes                   = list(any)
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
}

##Private Data Subnets
#variable "private_data_subnets" {
#  type = object({
#    routes                   = list(any)
#    cidrs_blocks             = list(string)
#    subnets_name_prefix      = string
#    route_table_name         = string
#    is_public                = bool
#  })
#}

##Private Services Subnets
#variable "private_services_subnets" {
#  type = object({
#    routes                   = list(any)
#    cidrs_blocks             = list(string)
#    subnets_name_prefix      = string
#    route_table_name         = string
#  })
#}

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



