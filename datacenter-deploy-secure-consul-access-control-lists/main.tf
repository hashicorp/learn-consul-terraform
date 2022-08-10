locals {
  aws_vpc_id        = random_string.cluster_id.id
  region            = "us-east-1"
  consul_cluster_id = random_string.cluster_id.id
  hcp_hvn_id        = random_string.cluster_id.id
}

resource "random_string" "cluster_id" {
  length  = 6
  special = false
  upper   = false
}

module "hcp" {
  source                 = "./modules/infra"
  aws_availability_zones = data.aws_availability_zones.azs_no_local_zones.names
  aws_vpc_id             = local.aws_vpc_id
  consul_cluster_id      = local.consul_cluster_id
  hvn_id                 = local.hcp_hvn_id
  region                 = local.region
  ami_id                 = data.aws_ami.amazon-linux-2.id
  aws_account_id         = data.aws_caller_identity.current.account_id
}
