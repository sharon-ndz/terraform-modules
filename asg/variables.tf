variable "asg_tgs" {
  description = "A list of tag blocks. Each element should have keys named key, value, and propagate_at_launch"
  type        = list(map(string))
  default     = []
}

variable "propagate_common_tags_at_launch" {
  description = "wheter propagate common tags at machines launched from ASG"
  type        = bool
  default     = false
}

################################################################################
# Instance Profile
################################################################################

variable "create_iam_role" {
  type        = bool
  description = "(optional) create IAM Role or not"
  default     = false
}

variable "created_instance_profile_name" {
    type = string
    description = "instance profile name"
}

variable "machine_iam_policies" {
  type = list(object(
  	{
  		policy_name = string,
  	  statements = list(object({
        Action   = list(string)
  		  Effect   = string
  		  Resource = list(string)
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

################################################################################
# Security Group
################################################################################

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

variable "vpc_id" {
  description = "The id of the vpc where the SGs created ."
  type        = string
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

################################################################################
# Autoscaling group
################################################################################

variable "create_asg" {
  description = "Determines whether to create autoscaling group or not"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name used across the resources created"
  type        = string
}

variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix"
  type        = bool
  default     = false
}

variable "instance_name" {
  description = "Name that is propogated to launched EC2 instances via a tag - if not provided, defaults to `var.name`"
  type        = string
  default     = ""
}

variable "launch_template" {
  description = "Name of an existing launch template to be used (created outside of this module)"
  type        = string
  default     = null
}

variable "lt_version" {
  description = "Launch template version. Can be version number, `$Latest`, or `$Default`"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "A list of one or more availability zones for the group. Used for EC2-Classic and default subnets when not specified with `vpc_zone_identifier` argument. Conflicts with `vpc_zone_identifier`"
  type        = list(string)
  default     = null
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = null
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = null
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = null
}

variable "capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled"
  type        = bool
  default     = null
}

variable "min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  type        = number
  default     = null
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior."
  type        = number
  default     = null
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  default     = null
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
  default     = null
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead"
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = null
}

variable "force_delete" {
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  type        = bool
  default     = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`"
  type        = list(string)
  default     = null
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your Auto Scaling Group from functioning properly"
  type        = list(string)
  default     = null
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds"
  type        = number
  default     = null
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = list(string)
  default     = null
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is `1Minute`"
  type        = string
  default     = null
}

variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
  default     = null
}

variable "initial_lifecycle_hooks" {
  description = "One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource"
  type        = list(map(string))
  default     = []
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type        = any
  default     = null
}

variable "use_mixed_instances_policy" {
  description = "Determines whether to use a mixed instances policy in the autoscaling group or not"
  type        = bool
  default     = false
}

variable "mixed_instances_policy" {
  description = "Configuration block containing settings to define launch targets for Auto Scaling groups"
  type        = any
  default     = null
}

variable "delete_timeout" {
  description = "Delete timeout to wait for destroying autoscaling group"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws_autoscaling_group requires."
  type        = map(string)
  default     = {}
}

variable "propagate_name" {
  description = "Determines whether to propagate the `var.instance_name`/`var.name` tag to launch instances"
  type        = bool
  default     = true
}

variable "warm_pool" {
  description = "If this block is configured, add a Warm Pool to the specified Auto Scaling group"
  type        = any
  default     = null
}

################################################################################
# Launch template
################################################################################

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "iam_instance_profile_name" {
  description = "The name attribute of the IAM instance profile to associate with launched instances"
  type        = string
  default     = null
}

variable "image_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "The Base64-encoded user data to provide when launching the instance. You should use this for Launch Templates instead user_data"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to associate"
  type        = list(string)
  default     = null
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = null
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default     = null
}

variable "create_lt" {
  description = "Determines whether to create launch template or not"
  type        = bool
  default     = true
}

variable "use_lt" {
  description = "Determines whether to use a launch template in the autoscaling group or not"
  type        = bool
  default     = true
}

variable "lt_name" {
  description = "Name of launch template to be created"
  type        = string
  default     = ""
}

variable "lt_use_name_prefix" {
  description = "Determines whether to use `lt_name` as is or create a unique name beginning with the `lt_name` as the prefix"
  type        = bool
  default     = false
}

variable "description" {
  description = "(LT) Description of the launch template"
  type        = string
  default     = null
}

variable "default_version" {
  description = "(LT) Default Version of the launch template"
  type        = string
  default     = null
}

variable "update_default_version" {
  description = "(LT) Whether to update Default Version each update. Conflicts with `default_version`"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "(LT) If true, enables EC2 instance termination protection"
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "(LT) Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
  type        = string
  default     = null
}

variable "kernel_id" {
  description = "(LT) The kernel ID"
  type        = string
  default     = null
}

variable "ram_disk_id" {
  description = "(LT) The ID of the ram disk"
  type        = string
  default     = null
}

variable "block_device_mappings" {
  description = "(LT) Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(any)
  default     = []
}

variable "capacity_reservation_specification" {
  description = "(LT) Targeting for EC2 capacity reservations"
  type        = any
  default     = null
}

variable "cpu_options" {
  description = "(LT) The CPU options for the instance"
  type        = map(string)
  default     = null
}

variable "credit_specification" {
  description = "(LT) Customize the credit specification of the instance"
  type        = map(string)
  default     = null
}

variable "elastic_gpu_specifications" {
  description = "(LT) The elastic GPU to attach to the instance"
  type        = map(string)
  default     = null
}

variable "elastic_inference_accelerator" {
  description = "(LT) Configuration block containing an Elastic Inference Accelerator to attach to the instance"
  type        = map(string)
  default     = null
}

variable "enclave_options" {
  description = "(LT) Enable Nitro Enclaves on launched instances"
  type        = map(string)
  default     = null
}

variable "hibernation_options" {
  description = "(LT) The hibernation options for the instance"
  type        = map(string)
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "(LT) The IAM Instance Profile ARN to launch the instance with"
  type        = string
  default     = null
}

variable "instance_market_options" {
  description = "(LT) The market (purchasing) option for the instance"
  type        = any
  default     = null
}

variable "license_specifications" {
  description = "(LT) A list of license specifications to associate with"
  type        = map(string)
  default     = null
}

variable "network_interfaces" {
  description = "(LT) Customize network interfaces to be attached at instance boot time"
  type        = list(any)
  default     = []
}

variable "placement" {
  description = "(LT) The placement of the instance"
  type        = map(string)
  default     = null
}

variable "tag_specifications" {
  description = "(LT) The tags to apply to the resources during launch"
  type        = list(any)
  default     = []
}

################################################################################
# Autoscaling group schedule
################################################################################

variable "create_schedule" {
  description = "Determines whether to create autoscaling group schedule or not"
  type        = bool
  default     = false
}

variable "schedules" {
  description = "Map of autoscaling group schedule to create"
  type        = map(any)
  default     = {}
}


################################################################################
# Autoscaling policy
################################################################################

variable "create_scaling_policy" {
  description = "Determines whether to create target scaling policy schedule or not"
  type        = bool
  default     = false
}

variable "scaling_policies" {
  description = "Map of target scaling policy schedule to create"
  type        = any
  default     = {}
}

#################################################################################
# Target Groups
#################################################################################
variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type        = any
  default     = []
}

#################################################################################
# HTTTP Listener Rules
#################################################################################
variable "http_tcp_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http_tcp_listener_index (default to http_tcp_listeners[count.index])"
  type        = any
  default     = []
}

#################################################################################
# HTTTPS Listener Rules
#################################################################################
variable "https_listener_rules" {
  description = "A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https_listener_index (default to https_listeners[count.index])"
  type        = any
  default     = []
}

#################################################################################
# HTTTP Listeners
#################################################################################
variable "http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type        = any
  default     = []
}

#################################################################################
# HTTTPS Listeners
#################################################################################
variable "https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to https_listeners[count.index])"
  type        = any
  default     = []
}

#################################################################################
# Extra SSL Certs
#################################################################################
variable "extra_ssl_certs" {
  description = "A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward)."
  type        = list(map(string))
  default     = []
}