resource "random_id" "tutorial" {
  byte_length = 2
}

data "aws_availability_zones" "this" {
  all_availability_zones = true
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

locals {
  vpc_azs = data.aws_availability_zones.this.names
#  vpc_azs = [
#    "us-west-2a",
#    "us-east-2b",
#    "us-east-2c",
#    "us-east-2d"
#  ]
  consul_datacenter   = "dc1-${random_id.tutorial.b64_url}"
  public_ecr_region   = var.aws_region
  unique_vpc          = "${var.cluster_definitions.name}-${random_id.tutorial.b64_url}"
  hcp_cloud_provider = "aws"

  tutorial_config = {
    aws_vpc_cidr_block          = module.vpc.vpc_cidr_block
    default_route_table_id      = module.vpc.default_route_table_id
    vpc_private_route_table_ids = module.vpc.private_route_table_ids
    vpc_public_route_table_ids  = module.vpc.public_route_table_ids
    aws_account_id              = data.aws_caller_identity.current.account_id
    private_subnets             = module.vpc.private_subnets
    public_subnets              = module.vpc.public_subnets
    security_group_ids          = [module.vpc.default_security_group_id]
    vpc_id                      = module.vpc.vpc_id
    aws_region                  = var.aws_region
    identifier                  = random_id.tutorial.b64_url
    consul_datacenter           = local.consul_datacenter
    hcp_cloud_provider          = local.hcp_cloud_provider
    hcp_consul_tier             = var.hcp_consul_tier
  }
}

data "aws_caller_identity" "current" {}
