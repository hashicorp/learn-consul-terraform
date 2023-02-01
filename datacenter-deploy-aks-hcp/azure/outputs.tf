# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "azure_rg_name" {
  value = azurerm_resource_group.rg.name
}

output "azure_nsg_name" {
  value = azurerm_network_security_group.nsg.name
}

output "azure_vnet_id" {
  value = module.network.vnet_id
}

output "azure_vnet_name" {
  value = module.network.vnet_name
}

output "azure_subnet_ids" {
  value = module.network.vnet_subnets
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}