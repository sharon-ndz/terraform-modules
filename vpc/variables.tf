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

###Private Subnets###
variable "private_subnet_name" {
  type = string
}
variable "vpc_private_subnets" {
  type = list
}
variable "private_route_cidr" {
  type = string
}
variable "private_route_table_name" {
  default = ""
}

###Public Subnets###
variable "map_public_ip_on_launch" {
  type = bool
}
variable "public_subnets_name" {
  type = string
}
variable "extra_public_routes" {
  type = list
}
variable "public_route_table_name" {
  type = string
}
variable "vpc_public_subnet_cidr" {
  type = list
}