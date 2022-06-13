terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.14.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.15.1"
    }

  }
}

provider "aws" {
  region = var.aws_region
}

