variable "region" {
  description = "AWS region to launch servers."
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "adperfect-us-west-2"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/id_rsa.pub
DESCRIPTION


  default = "/aws/adperfect-us-west-2.pub"
}

variable "environment" {
  description = "Environment to launch in. One of: dev, stage, prod"
  default     = "prod"
}

variable "application" {
  description = "The application that this is terraforming"
  default     = ""
}

variable "brand" {
  description = "The brand that this is terraforming"
  default     = ""
}

variable "cloudwatch_comparison_operator" {
}

variable "cloudwatch_data_points_to_alarm" {
}

variable "cloudwatch_evaluation_periods" {
}

variable "cloudwatch_metric_name" {
}

variable "cloudwatch_namespace" {
}

variable "cloudwatch_dimensions" {
  type = map(string)
}

variable "cloudwatch_period" {
}

variable "cloudwatch_statistic" {
}

variable "cloudwatch_threshold" {
}

variable "cloudwatch_treat_missing_data" {
}

variable "cloudwatch_insufficient_data_actions" {
  type = list(string)
}

#variable "notify_slack" {
#  description = "The slack notification toggle. Set to 1 to enable."
#}
#
#variable "endpoint_slack" {
#  description = "The slack notification endpoint"
#}

variable "notify_teams" {
  description = "The Teams notification toggle. Set to 1 to enable."
}

variable "endpoint_teams" {
  description = "The Teams notification email endpoint"
}

variable "notify_pagerduty_integration_key" {
  description = "The integration key of the manually created pagerduty service"
}

variable "notify_emails" {
  type        = list(string)
  description = "The list of email addresses to notify"
}
