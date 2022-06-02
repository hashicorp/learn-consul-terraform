locals {
  network_region = "West US 2"
  hvn_region     = "westus2"
  cluster_id     = "learn-hcp-consul-vm-client1"
  hvn_id         = "${local.cluster_id}-hvn"
  tier           = "development"
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${local.cluster_id}-gid"
  location = local.network_region
}

resource "azurerm_route_table" "rt" {
  name                = "${local.cluster_id}-rt"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.cluster_id}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "network" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_cidrs
  subnet_prefixes     = values(var.vnet_subnets)
  subnet_names        = keys(var.vnet_subnets)
  vnet_name           = "${local.cluster_id}-vnet"

  # Every subnet will share a single route table
  route_tables_ids = { for i, subnet in keys(var.vnet_subnets) : subnet => azurerm_route_table.rt.id }

  # Every subnet will share a single network security group
  nsg_ids = { for i, subnet in keys(var.vnet_subnets) : subnet => azurerm_network_security_group.nsg.id }

  depends_on = [azurerm_resource_group.rg]
}

resource "hcp_hvn" "hvn" {
  hvn_id         = local.hvn_id
  cloud_provider = "azure"
  region         = local.hvn_region
  cidr_block     = "172.25.32.0/20"
}

module "hcp_peering" {
  source  = "hashicorp/hcp-consul/azurerm"
  version = "~> 0.2.0"

  # Required
  tenant_id       = data.azurerm_subscription.current.tenant_id
  subscription_id = data.azurerm_subscription.current.subscription_id
  hvn             = hcp_hvn.hvn
  vnet_rg         = azurerm_resource_group.rg.name
  vnet_id         = module.network.vnet_id
  subnet_ids      = module.network.vnet_subnets

  # Optional
  security_group_names = [azurerm_network_security_group.nsg.name]
  prefix               = local.cluster_id
}

resource "hcp_consul_cluster" "main" {
  cluster_id      = local.cluster_id
  hvn_id          = hcp_hvn.hvn.hvn_id
  public_endpoint = true
  tier            = local.tier
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}
