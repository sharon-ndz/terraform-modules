variable "name" {
  description = "The name of the Load Balancer"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
}

variable "load_balancer_type" {
  description = "The type of the load balancer: application or network"
  type        = string
  default     = "network"
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the LB will be deployed"
  type        = string
}

variable "subnet_mapping" {
  description = "List of subnet mappings for the load balancer"
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string)
    private_ipv4_address = optional(string)
    ipv6_address         = optional(string)
  }))
}

variable "target_ips" {
  description = "List of EC2 instance private IPs to register in target group"
  type        = list(string)
}

variable "target_port" {
  description = "The port on which targets (EC2s) listen"
  type        = number
}

variable "create_sg" {
  description = "Whether to create a security group for the LB"
  type        = bool
  default     = true
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_roles" {
  description = "Ingress rules for the security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    self             = bool
  }))
}

variable "egress_roles" {
  description = "Egress rules for the security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    self             = bool
  }))
}

#variable "access_logs_bucket" {
  #description = "S3 bucket name for storing NLB access logs"
 # type        = string
#}

#variable "access_logs_prefix" {
  #description = "Prefix inside S3 bucket for NLB access logs"
  #type        = string
 # default     = "Prefix within the S3 bucket for NLB access logs"
#}

variable "environment" {
  description = "Environment name (e.g. dev, stage, prod)"
  type        = string
}

