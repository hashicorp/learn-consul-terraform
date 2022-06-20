# The HCP HVN Resource. Hosts the HCP Vault and Cluster instances
resource "hcp_hvn" "server" {
  cloud_provider = var.resource_config.hcp_cloud_provider
  hvn_id         = local.unique_hvn
  region         = var.resource_config.aws_region
  cidr_block     = var.resource_config.hcp_hvn_cidr_block
}

# Creates the HCP Consul Server instance
resource "hcp_consul_cluster" "server" {
  # When datacenter variable is not passed to this resource, the consul datacenter name is the value of required variable `cluster_id`
  cluster_id      = var.resource_config.hcp_consul_datacenter
  hvn_id          = hcp_hvn.server.hvn_id
  public_endpoint = var.resource_config.enable_hcp_consul_endpoint
  tier            = var.resource_config.hcp_consul_tier
  connect_enabled = true
}

# From HCP, creating a peering relationship that generates the pcx-id in AWS.
resource "hcp_aws_network_peering" "default" {
  hvn_id          = hcp_hvn.server.hvn_id
  peer_vpc_id     = var.resource_config.aws_vpc_id
  peer_vpc_region = var.resource_config.aws_region
  peer_account_id = var.resource_config.aws_account_id
  peering_id      = local.unique_peering_id
}

# Create an hcp route that that has a destination CIDR of the AWS VPC
resource "hcp_hvn_route" "peering_route" {
  hvn_link         = hcp_hvn.server.self_link
  hvn_route_id     = local.unique_route_id
  destination_cidr = var.resource_config.aws_vpc_cidr_block
  target_link      = hcp_aws_network_peering.default.self_link
  depends_on       = [aws_vpc_peering_connection_accepter.peer]
}

# Creates the root Consul token for the working environment
resource "hcp_consul_cluster_root_token" "user" {
  depends_on = [hcp_consul_cluster.server]
  cluster_id = var.resource_config.hcp_consul_datacenter
}

