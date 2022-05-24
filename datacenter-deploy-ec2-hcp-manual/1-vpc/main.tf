locals {
  vpc_region = var.region
  hvn_region = var.region
  cluster_id = var.name
  hvn_id     = "${var.name}-hvn"
}

provider "aws" {
  region = local.vpc_region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

// VPC and underlying network resources
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name                 = "${local.cluster_id}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = []
  enable_dns_hostnames = true
}
