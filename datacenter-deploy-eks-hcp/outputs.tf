output "consul_ui_address" {
  value = hcp_consul_cluster.example.consul_public_endpoint_url
}