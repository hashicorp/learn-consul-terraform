locals {
  raw_config = jsondecode(base64decode(hcp_consul_cluster.server.consul_config_file))
  gossip_key = local.raw_config["encrypt"]
}

output "consul_bootstrap_token" {
  value = hcp_consul_cluster.server.consul_root_token_secret_id
}

output "ca_certificate_file" {
  value = base64decode(hcp_consul_cluster.server.consul_ca_file)
}

output "hcp_consul_endpoint" {
  value = hcp_consul_cluster.server.consul_private_endpoint_url
}

output "hcp_consul_public_endpoint" {
  value = hcp_consul_cluster.server.consul_public_endpoint_url
}

output "consul_gossip_key" {
  value = local.gossip_key
}

output "hcp_datacenter" {
  value = hcp_consul_cluster.server.datacenter
}

