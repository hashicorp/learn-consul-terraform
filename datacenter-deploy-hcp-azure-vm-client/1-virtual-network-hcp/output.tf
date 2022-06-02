output "hcp_consul_cluster_id" {
  value = hcp_consul_cluster.main.cluster_id
}

output "consul_root_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "consul_url" {
  value = hcp_consul_cluster.main.consul_public_endpoint_url
}

output "azurerm_resource_group" {
  value = azurerm_resource_group.rg.name
}

output "azurerm_nsg" {
  value = azurerm_network_security_group.nsg.name
}

output "prefix" {
  value = local.cluster_id
}

output "subnet_id" {
  value = module.network.vnet_subnets[0]
}
