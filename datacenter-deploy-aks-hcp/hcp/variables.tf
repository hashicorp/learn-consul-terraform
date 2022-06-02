// HashiCorp Cloud Platform (HCP) Variables

variable "hvn_region" {
  type        = string
  description = "the hvn region"
  default     = "westus2"
}

variable "hvn_id" {
  type        = string
  description = "the hvn id"
  default     = "learn-hcp-consul-aks-client-hvn"
}

variable "hvn_cidr_block" {
  type        = string
  description = "The cidr block of the hvn"
  default     = "172.25.16.0/20"
}

// Azure variables

variable "network_region" {
  type        = string
  description = "the network region"
  default     = "West US 2"
}

variable "cluster_id" {
  type        = string
  description = "The cluster id is unique. All other unique values will be derived from this (resource group, vnet etc)"
  default     = "learn-hcp-consul-aks-client"
}

variable "tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "development"
}

variable "azure_vnet_name" {
  type        = string
  description = "Azure virtual network name"
  default     = ""
}

variable "azure_vnet_id" {
  type        = string
  description = "Azure virtual network id"
  default     = ""
}

variable "azure_rg_name" {
  type        = string
  description = "Azure resource group name"
  default     = ""
}

variable "azure_nsg_name" {
  type        = string
  description = "Azure network security group name"
  default     = ""
}

variable "azure_subnet_ids" {
  type        = list(string)
  description = "Azure subnet ids"
  default     = []
}
