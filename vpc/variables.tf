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
  default = false
}
variable "enable_dns_hostnames" {
  type = bool
  default = false
}
variable "vpc_name" {
  type = string
  default = ""
}
variable "vpc_cidr" {
  type = string
  default = ""
}

###IGW###
variable "internet_gateway_name" {
  type = string
  default = ""
}

###NGW###
variable "total_nat_gateway_required" {
  type = number
  default = 0
}
variable "eip_for_nat_gateway_name" {
  type = string
  default = ""
}
variable "nat_gateway_name" {
  type = string
  default = ""
}

###Private Subnets###
variable "private_app_subnets" {
  type = object({
    routes                   = list
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
  default = {}
}

##Private Data Subnets
variable "private_data_subnets" {
  type = object({
    routes                   = list
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
  default = {}
}

##Private Services Subnets
variable "private_services_subnets" {
  type = object({
    routes                   = list
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    route_table_name         = string
  })
  default = {}
}

###Public Subnets###
variable "public_subnets" {
  type = object({
    routes                   = list
    cidrs_blocks             = list(string)
    subnets_name_prefix      = string
    map_public_ip_on_launch  = bool
    route_table_name         = string
  })
  default = {}
}