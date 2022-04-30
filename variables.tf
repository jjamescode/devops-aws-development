variable "application_name" {
  type        = string
  description = "Application Name"
  default     = "task1"
}

variable "application_env" {
  type        = string
  description = "Application Environment"
  default     = "dev"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "172.20.0.0/20"
}

variable "pub_web_subnets_cidr" {
  type    = list(any)
  default = ["172.20.1.0/24", "172.20.2.0/24"]
}

variable "priv_app_subnets_cidr" {
  type    = list(any)
  default = ["172.20.3.0/24", "172.20.4.0/24"]
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}

variable "bastion_key_name" {
  default = "unbun-key"
}
