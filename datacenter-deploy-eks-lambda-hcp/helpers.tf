resource "random_id" "tutorial" {
  byte_length = 2
}

locals {
  vpc_azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d"
  ]
  unique_vpc = "${var.cluster_definitions.name}-${random_id.tutorial.b64_url}"
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
    # consul_enterprise_license   = file(var.consul_enterprise_license_filename)
    aws_region = var.aws_region
    identifier = random_id.tutorial.b64_url
  }
}

data "aws_caller_identity" "current" {}
