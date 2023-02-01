# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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
variable "hcp_consul_cluster_id" {
  type        = string
  description = "The cluster id is unique. All other unique values will be derived from this (resource group, vnet etc)"
  default     = "learn-hcp-consul-aks-client"
}

variable "hcp_consul_tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "development"

  validation {
    condition     = contains(["development", "standard", "plus"], var.hcp_consul_tier)
    error_message = "HCP Consul tier must be development, standard, or plus."
  }
}

variable "azure_vnet_name" {
  type        = string
  description = "Azure virtual network name"
}

variable "azure_vnet_id" {
  type        = string
  description = "Azure virtual network id"
}

variable "azure_rg_name" {
  type        = string
  description = "Azure resource group name"
}

variable "azure_nsg_name" {
  type        = string
  description = "Azure network security group name"
}

variable "azure_subnet_ids" {
  type        = list(string)
  description = "Azure subnet ids"
}
