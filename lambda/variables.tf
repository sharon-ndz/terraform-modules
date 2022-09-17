variable "lambda_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "filename" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "runtime" {
  type = string
}

variable "memsize" {
  type = string
}

variable "publish" {
}

variable "lambda_vars" {
  type = map(string)
}

variable "tags" {
  default = {}
  type    = map(string)
}
