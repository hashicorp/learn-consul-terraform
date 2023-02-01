# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
}

provider "hcp" {}

data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "vnet" {
  name                = var.azure_vnet_name
  resource_group_name = var.azure_rg_name
}

resource "hcp_hvn" "hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = "azure"
  region         = var.hvn_region
  cidr_block     = var.hvn_cidr_block
}

resource "hcp_consul_cluster" "main" {
  cluster_id      = var.hcp_consul_cluster_id
  hvn_id          = hcp_hvn.hvn.hvn_id
  public_endpoint = true
  tier            = var.hcp_consul_tier
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

// Step 2 - Set up peering connection: connect Azure VNets to HVN
module "hcp_peering" {
  source  = "hashicorp/hcp-consul/azurerm"
  version = "~> 0.2.3"

  # Required
  tenant_id       = data.azurerm_subscription.current.tenant_id
  subscription_id = data.azurerm_subscription.current.subscription_id
  hvn             = hcp_hvn.hvn
  vnet_rg         = var.azure_rg_name
  vnet_id         = var.azure_vnet_id
  subnet_ids      = var.azure_subnet_ids

  # Optional
  security_group_names = [var.azure_nsg_name]
  prefix               = var.hcp_consul_cluster_id
}

resource "azurerm_network_security_rule" "ingress_gw" {
  name                        = "ingress-gateway"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "8080"
  resource_group_name         = var.azure_rg_name
  network_security_group_name = var.azure_nsg_name
}
