output "vm_client" {
  value = azurerm_linux_virtual_machine.consul_client[0].public_ip_address
}

output "consul_url" {
  value = data.hcp_consul_cluster.selected.public_endpoint ? (
    data.hcp_consul_cluster.selected.consul_public_endpoint_url
    ) : (
    data.hcp_consul_cluster.selected.consul_private_endpoint_url
  )
}

output "consul_root_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}
