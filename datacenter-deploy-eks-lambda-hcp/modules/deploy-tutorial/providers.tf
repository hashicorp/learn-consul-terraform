terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.14.0"
    }
    aws = {
      source = "hashicorp/aws"
    }

  }
}

provider "aws" {
  region = var.tutorial_config.aws_region
}

