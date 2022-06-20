locals {
  rand = lower(random_id.tutorial.b64_url)

  hcp_cloud_provider       = var.tutorial_networking.hcp_cloud_provider
  aws_region               = var.aws_region
  unique_consul_datacenter = "dc1-${local.rand}"
  unique_vpc               = "${var.tutorial_networking.vpc.name}-${local.rand}"
  unique_kube_cluster_name = "${var.eks_cluster_configuration.name}-${local.rand}"

  tutorial_config = {
    aws_account_id     = data.aws_caller_identity.current.account_id
    aws_region         = local.aws_region
    random_identifier  = local.rand
    aws_vpc_cidr_block = var.tutorial_networking.vpc.cidr_block
    private_subnets    = var.tutorial_networking.vpc.private_subnets
    public_subnets     = var.tutorial_networking.vpc.public_subnets
    hcp_datacenter  = local.unique_consul_datacenter
    hcp_cloud_provider = local.hcp_cloud_provider
    hcp_consul_tier    = var.hcp_consul_tier
    vpc_name           = local.unique_vpc
    eks_cluster_name   = local.unique_kube_cluster_name
    aws_profile_name   = "default"
    hcp_hvn_cidr_block = var.tutorial_networking.hcp_hvn_cidr_block
    hvn_peering_identifier = var.tutorial_networking.hvn_peering_identifier
    eks_cluster_stage  = "dev"
    hcp_hvn            = var.tutorial_networking.hcp_hvn
  }
}

resource "random_id" "tutorial" {
  byte_length = 2
}

