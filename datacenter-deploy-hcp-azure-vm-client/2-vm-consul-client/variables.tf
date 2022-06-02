variable "hcp_consul_cluster_id" {
  type        = string
  description = "HCP Consul Cluster ID"
  default     = ""
}

variable "azurerm_resource_group" {
  type        = string
  description = "Azure resource group"
  default     = ""
}

variable "prefix" {
  type        = string
  description = "project prefix"
  default     = "learn-hcp-consul-azure-vm"
}

variable "subnet_id" {
  type        = string
  description = "Azure subnet ID"
  default     = ""
}

variable "azurerm_nsg" {
  type        = string
  description = "Azure Network security group"
  default     = ""
}
