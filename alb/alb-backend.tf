# where alb state file stored
terraform {
  backend "s3" {
    bucket         = "aws-terra-dev1-tfstate"
    key            = "alb-aws-terra.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "aws-terra-dev1-tfstate-lock"
  }
}