locals {
  eks_config = {
    private_subnets            = var.tutorial_config.private_subnets
    public_subnets             = var.tutorial_config.public_subnets
    security_group_ids         = var.tutorial_config.security_group_ids
    vpc_id                     = var.tutorial_config.vpc_id
    consul_ent_license_b64     = var.tutorial_config.consul_enterprise_license
    consul_bootstrap_token_b64 = module.hcp-tutorial-deployment.consul_bootstrap_token
    consul_ca_certificate_b64  = module.hcp-tutorial-deployment.ca_certificate_file
    consul_gossip_key_b64      = module.hcp-tutorial-deployment.consul_gossip_key
    hcp_consul_endpoint        = module.hcp-tutorial-deployment.hcp_consul_endpoint
    aws_region                 = var.aws_region
    identifier                 = var.tutorial_config.identifier
    hcp_datacenter             = module.hcp-tutorial-deployment.hcp_datacenter
  }
  hcp_config = {
    aws_account_id             = var.tutorial_config.aws_account_id
    aws_default_route_table_id = var.tutorial_config.default_route_table_id
    aws_region                 = var.aws_region
    aws_vpc_cidr_block         = var.tutorial_config.aws_vpc_cidr_block
    aws_vpc_id                 = var.tutorial_config.vpc_id
    private_route_table_ids    = var.tutorial_config.vpc_private_route_table_ids
    public_route_table_ids     = var.tutorial_config.vpc_public_route_table_ids
    identifier                 = var.tutorial_config.identifier
  }
  lambda_config = {
    aws_account_id           = var.tutorial_config.aws_account_id
    consul_ca_cert           = module.hcp-tutorial-deployment.ca_certificate_file
    kubernetes_control_plane = module.eks-tutorial-deployment.kubernetes_control_plane
    private_subnets          = var.tutorial_config.private_subnets
    region                   = var.tutorial_config.aws_region
    security_groups          = var.tutorial_config.security_group_ids
    identifier               = var.tutorial_config.identifier
  }
}