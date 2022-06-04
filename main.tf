# where state file stored
terraform {
  backend "s3" {
    bucket         = "aws-terra-dev1-tfstate"
    key            = "aws-terra.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "aws-terra-dev1-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}


locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.application_name
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}