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