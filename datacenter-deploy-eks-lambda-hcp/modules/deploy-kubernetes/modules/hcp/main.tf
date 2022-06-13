# The HCP HVN Resource. Hosts the HCP Vault and Cluster instances
resource "hcp_hvn" "server" {
  cloud_provider = var.cloud_provider
  hvn_id         = local.unique_hvn
  region         = var.hcp_region
  cidr_block     = var.hcp_hvn_cidr_block
}

# Creates the HCP Consul Server instance
resource "hcp_consul_cluster" "server" {
  # When datacenter variable is not passed to this resource, the consul datacenter name is the value of required variable `cluster_id`
  cluster_id      = local.unique_consul_dc
  hvn_id          = hcp_hvn.server.hvn_id
  public_endpoint = var.consul_public_endpoint
  tier            = var.hcp_consul_tier
  connect_enabled = true
}

# From HCP, creating a peering relationship that generates the pcx-id in AWS.
resource "hcp_aws_network_peering" "default" {
  hvn_id          = hcp_hvn.server.hvn_id
  peer_vpc_id     = var.hcp_config.aws_vpc_id
  peer_vpc_region = var.hcp_config.aws_region
  peer_account_id = var.hcp_config.aws_account_id
  peering_id      = local.unique_peering_id
}

# Create routes for HCP Peering to the private routing table
resource "aws_route" "hcp_peering_private" {
  count                     = length(var.hcp_config.private_route_table_ids)
  route_table_id            = var.hcp_config.private_route_table_ids[count.index]
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  destination_cidr_block    = var.hcp_hvn_cidr_block
}

# Create routes for HCP Peering to the public route table.
resource "aws_route" "hcp_peering_public" {
  count                     = length(var.hcp_config.public_route_table_ids)
  route_table_id            = var.hcp_config.public_route_table_ids[count.index]
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  destination_cidr_block    = var.hcp_hvn_cidr_block
}

# Create an accepter from the hcp_aws_network_peering pcx-id
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

# Create an hcp route that that has a destination CIDR of the AWS VPC
resource "hcp_hvn_route" "peering_route" {
  hvn_link         = hcp_hvn.server.self_link
  hvn_route_id     = local.unique_route_id
  destination_cidr = var.hcp_config.aws_vpc_cidr_block
  target_link      = hcp_aws_network_peering.default.self_link
  depends_on       = [aws_vpc_peering_connection_accepter.peer]
}

# Create an AWS Route to the default route table for the HCP Peer
resource "aws_route" "peering-public" {
  route_table_id            = var.hcp_config.aws_default_route_table_id
  destination_cidr_block    = var.hcp_hvn_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

# Creates the root Consul token for the working environment
resource "hcp_consul_cluster_root_token" "user" {
  depends_on = [hcp_consul_cluster.server]
  cluster_id = local.unique_consul_dc
}

# Security Group created for the AWS VPC. This eventually holds the settings for peering between HCP and AWS.
resource "aws_security_group" "open" {
  vpc_id = var.hcp_config.aws_vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

}


