terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.42.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.14.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "hcp" {
  client_id = var.hcp_client_id
  client_secret = var.hcp_client_secret
}