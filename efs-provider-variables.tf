provider "aws" {
  profile = "ashish-college"
  region  = "ap-south-1"
  version = ">= 2.38.0"
}

provider "kubernetes" {}

data "aws_efs_file_system" "demo" {
    creation_token = "efs-eks"
}

output "demo" {
    value = data.aws_efs_file_system.demo
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "terraform-prom-graf-namespace"
  }
}
