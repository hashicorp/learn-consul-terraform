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

variable "vnet_cidrs" {
  type        = list(string)
  description = "The ciders of the vnet. This should make sense with vnet_subnets"
  default     = ["10.1.0.0/16"]
}

variable "vnet_subnets" {
  type        = map(string)
  description = "The subnets associated with the vnet"
  default = {
    "subnet1" = "10.1.1.0/24",
    "subnet2" = "10.1.2.0/24",
    "subnet3" = "10.1.3.0/24",
  }
}

// AKS Variables

variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}
