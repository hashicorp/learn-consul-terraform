locals {
  unique_hvn        = "${var.hvn_name}-${var.hcp_config.identifier}"
  unique_peering_id = "${var.hvn_peering_identifier}-${var.hcp_config.identifier}"
  unique_route_id   = "${hcp_hvn.server.hvn_id}-${var.hcp_config.identifier}"
}