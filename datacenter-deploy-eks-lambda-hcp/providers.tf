terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">=1.7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

