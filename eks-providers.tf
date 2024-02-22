provider "aws" {
  profile = "ashish-college"
  region  = "ap-south-1"
  version = ">= 2.38.0"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "http" {}
