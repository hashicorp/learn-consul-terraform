resource "hcp_consul_cluster" "example" {
  cluster_id      = "dc1"
  hvn_id          = hcp_hvn.server.hvn_id
  tier            = "development"
  public_endpoint = true
}