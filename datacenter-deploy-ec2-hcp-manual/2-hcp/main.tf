locals {
  vpc_region = var.region
  hvn_region = var.region
  cluster_id = var.name
  hvn_id     = "${var.name}-hvn"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

provider "aws" {
  region = local.vpc_region
}

resource "hcp_hvn" "main" {
  hvn_id         = local.hvn_id
  cloud_provider = "aws"
  region         = local.hvn_region
  cidr_block     = "172.25.32.0/20"
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.7.0"

  hvn             = hcp_hvn.main
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.public_subnets
  route_table_ids = data.terraform_remote_state.vpc.outputs.public_route_table_ids
}

resource "hcp_consul_cluster" "main" {
  cluster_id      = local.cluster_id
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = true
  tier            = "development"
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}
