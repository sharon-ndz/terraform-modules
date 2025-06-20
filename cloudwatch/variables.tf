variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "access_logs_prefix" {
  description = "Prefix for NLB access logs in the S3 bucket"
  type        = string
}

variable "tf_state_bucket" {
  description = "Terraform remote state S3 bucket name"
  type        = string
}

variable "retention_in_days" {
  description = "Retention period for log group"
  type        = number
  default     = 7
}

variable "log_group_tag_name" {
  description = "Tag name for the log group"
  type        = string
}

variable "ssm_param_name" {
  description = "Name of the SSM parameter for CloudWatch agent config"
  type        = string
}

variable "metrics_collection_interval" {
  description = "Interval for metrics collection in seconds"
  type        = number
  default     = 60
}

variable "cloudwatch_agent_logfile" {
  description = "Path to the CloudWatch agent logfile"
  type        = string
  default     = "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
}

variable "docker_log_file_path" {
  description = "Path pattern to Docker container logs"
  type        = string
  default     = "/var/lib/docker/containers/*/*.log"
}

variable "docker_log_group_name" {
  description = "CloudWatch log group name for Docker logs"
  type        = string
}

variable "log_stream_name" {
  description = "Log stream name pattern"
  type        = string
  default     = "{instance_id}/docker-api"
}

variable "timezone" {
  description = "Timezone setting for CloudWatch agent"
  type        = string
  default     = "UTC"
}

variable "ssm_tag_name" {
  description = "Tag name for the SSM parameter"
  type        = string
}

variable "access_logs_bucket" {
  description = "Name of the S3 bucket for NLB access logs"
  type        = string
}

variable "nlb_logs_bucket_tag_name" {
  description = "Name tag for the S3 bucket storing NLB logs"
  type        = string
  default     = "NLB Access Logs"
}
