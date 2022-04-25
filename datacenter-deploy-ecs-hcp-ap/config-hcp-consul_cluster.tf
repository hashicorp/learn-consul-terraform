
resource "hcp_consul_cluster" "example" {
  hvn_id          = hcp_hvn.server.hvn_id
  cluster_id      = local.unique_consul
  tier            = local.cluster_tier
  public_endpoint = local.hcp_consul_public
  connect_enabled = local.hcp_connect_enabled
  datacenter      = local.consul_dc

}