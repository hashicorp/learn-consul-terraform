locals {
  vpc_azs = data.aws_availability_zones.this.names

  resource_config = {
    identifier                  = var.tutorial_config.random_identifier
    aws_account_id              = var.tutorial_config.aws_account_id
    aws_default_route_table_id  = module.vpc.default_route_table_id
    aws_region                  = var.tutorial_config.aws_region
    aws_vpc_cidr_block          = var.tutorial_config.aws_vpc_cidr_block
    aws_vpc_id                  = module.vpc.vpc_id
    aws_eks_cluster_name        = var.tutorial_config.eks_cluster_name
    aws_cluster_stage           = var.tutorial_config.eks_cluster_stage
    aws_private_route_table_ids = module.vpc.private_route_table_ids
    aws_public_route_table_ids  = module.vpc.public_route_table_ids
    aws_public_subnets          = module.vpc.public_subnets
    aws_private_subnets         = module.vpc.private_subnets
    aws_security_group_ids      = [module.vpc.default_security_group_id]
    aws_profile_name            = var.tutorial_config.aws_profile_name
    hcp_consul_datacenter       = var.tutorial_config.hcp_datacenter
    hcp_cloud_provider          = var.tutorial_config.hcp_cloud_provider
    hcp_consul_tier             = var.tutorial_config.hcp_consul_tier
    hcp_hvn                     = var.tutorial_config.hcp_hvn
    hcp_hvn_cidr_block          = var.tutorial_config.hcp_hvn_cidr_block
    hvn_peering_identifier      = var.tutorial_config.hvn_peering_identifier
    enable_hcp_consul_endpoint  = true
  }
}
