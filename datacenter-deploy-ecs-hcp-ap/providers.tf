terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.0.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.14.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.15.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }
}



provider "time" {}

provider "aws" {
  region = var.region
}

provider "consul" {
  address    = hcp_consul_cluster.example.consul_public_endpoint_url
  token      = hcp_consul_cluster.example.consul_root_token_secret_id
  datacenter = var.hcp_datacenter_name
}

provider "hcp" {}
