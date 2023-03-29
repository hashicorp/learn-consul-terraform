# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "hcp_aws_network_peering" "default" {
  peer_account_id = data.aws_caller_identity.current.account_id
  peering_id      = local.peering_id
  peer_vpc_region = var.region
  peer_vpc_id     = module.vpc.vpc_id
  hvn_id          = hcp_hvn.server.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route" {
  hvn_route_id     = local.peering_id_hvn_route
  target_link      = hcp_aws_network_peering.default.self_link
  hvn_link         = hcp_hvn.server.self_link
  destination_cidr = module.vpc.vpc_cidr_block

}

resource "aws_route" "public_to_hvn" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id            = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.server.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

resource "aws_route" "private_to_hvn" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.server.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}