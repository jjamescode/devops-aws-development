variable "application_name" {
  type        = string
  description = "Application Name"
  default     = "app1"
}

variable "application_env" {
  type        = string
  description = "Application Environment"
  default     = "dev"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}

variable "prefix" {
  default = "app1"
}

variable "contact" {
  default = "emailgoeshere@email.com"
