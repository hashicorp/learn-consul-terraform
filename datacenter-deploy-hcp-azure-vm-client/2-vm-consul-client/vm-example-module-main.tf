locals {
  network_region = "West US 2"
  hvn_region     = "westus2"
  cluster_id     = "learn-hcp-consul-vm-client"
  hvn_id         = "learn-hcp-consul-vm-client-hvn"
  tier           = "development"
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = "${local.cluster_id}-gid"
}

data "azurerm_network_security_group" "nsg" {
  name = "${local.cluster_id}-nsg"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "sn" {
  name                 = "subnet1"
  virtual_network_name = "${local.cluster_id}-vnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "hcp_consul_cluster" "main" {
  cluster_id = local.cluster_id
  #cluster_id = var.cluster_id
}

data "hcp_hvn" "hvn" {
  hvn_id = data.hcp_consul_cluster.main.hvn_id
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = data.hcp_consul_cluster.main.id
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "vm_client" {
  source  = "hashicorp/hcp-consul/azurerm//modules/hcp-vm-client"
  version = "~> 0.2.0"

  resource_group = data.azurerm_resource_group.rg.name
  location       = data.azurerm_resource_group.rg.location

  nsg_name                 = data.azurerm_network_security_group.nsg.name
  allowed_ssh_cidr_blocks  = ["0.0.0.0/0"]
  allowed_http_cidr_blocks = ["0.0.0.0/0"]
  subnet_id                = data.azurerm_subnet.sn.id

  client_config_file = data.hcp_consul_cluster.main.consul_config_file
  client_ca_file     = data.hcp_consul_cluster.main.consul_ca_file
  root_token         = hcp_consul_cluster_root_token.token.secret_id
  ssh_public_key     = tls_private_key.ssh.public_key_openssh
  consul_version     = data.hcp_consul_cluster.main.consul_version
}