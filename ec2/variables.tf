variable "ami" {
  type = string
}

variable "instance_name" {
  description = "NetBIOS name of the domain"
  type        = string
  default     = ""
}

variable "instance_profile_name" {
    type = string
    description = "instance profile name"
}

variable "instance_type" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "encryption_kms_key_id" {
  type = string
}

variable "security_groups_ids" {
    type = list(string)
    description = "(optional) ids of the SGs to be attahced to the instance"
    default = []
}

variable "create_sg" {
    type        = bool
    description = "(optional) create sg or not"
    default     = false
}

variable "sg_name" {
    type        = string
    description = "(optional) security group name"
    default     = ""
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

variable "root_block_device" {
  type = object({
      volume_size             = number
      volume_type             = string
      delete_on_termination   = bool
      encrypted               = bool
      iops                    = string
      tags                    = object({})
  })
}

variable "machine_iam_policies" {
  type = list(object(
  	{
  		policy_name = string,
  	    statement = list(object({
  		    action   = list(string)
  		    effect   = string
  		    resource = string
  		}))
  	}
  ))
  default = []
}

variable "machine_extra_policies_arns" {
  type = list(string)
  description = "AWS ARNs for extra policies"
  default = []
}

variable "ingress_roles" {
  type = list(object({
      description       = string
      from_port         = string
      to_port           = string
      protocol          = string
      cidr_blocks       = list(string)
      ipv6_cidr_blocks  = list(string)
      security_groups   = list(string)
      self              = bool
    }
  ))
  default = []
}

variable "egress_roles" {
  type = list(object({
      description       = string
      from_port         = string
      to_port           = string
      protocol          = string
      cidr_blocks       = list(string)
      ipv6_cidr_blocks  = list(string)
      security_groups   = list(string)
      self              = bool
    }
  ))
  default = []
}

variable "vpc_id" {
  description = "The id of the vpc where the SGs created ."
  type        = string
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "secondary_private_ips" {
  type    = list(string)
  default = []
}

variable "private_ip" {
  type        = string
  description = "private ip"
  default     = ""
}

variable "script" {
  type    = string
  default = ""
}
variable "common_tags" {
  type = map(string)
}

variable "volumes" {
  type = list(object({
    device_name           = string
    delete_on_termination = bool
    volume_size           = number
    volume_type           = string
    encrypted             = bool
    kms_key_id            = string
    iops                  = string
    tags                  = object({})
  }))
  default = []
}

variable "networks" {
  type = list(object({
    subnet_id       = string
    private_ips     = list(string)
    security_groups = list(string)
    device_index    = number
  }))
  default = []
}

variable "disks_list" {
  description = "Use each disk,Letter,Label then '|' to add another disk"
  type        = string
  default     = ""
}

variable "is_linux" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type = string
  description = "subnet id for creation of the EC2 instance"
}

variable "create_zone_record" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "record_name" {
  type = string
}

variable "record_type" {
  type = string
}

variable "record_ttl" {
  type = string
}