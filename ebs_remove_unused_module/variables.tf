# See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
# for how to write schedule expressions
variable "schedule_expression" {
  default     = ""
  description = "The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes)"
}

variable "region" {
  default     = ""
  description = "AWS Region where module should operate (e.g. `us-east-1`)"
}

variable "env" {}