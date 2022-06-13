variable "cloud_provider" {
  type        = string
  description = "Cloud Provider for HCP"
  default     = "aws"
}

variable "hvn_name" {
  default = "lambdaConsul"
}

variable "hcp_region" {
  default = "us-east-1"
}

variable "hcp_hvn_cidr_block" {
  type        = string
  description = "CIDR block for HCP"
  default     = "172.25.0.0/16"
}

variable "consul_cluster_datacenter" {
  type        = string
  description = "Consul cluster datacenter"
  default     = "dc1"
}

variable "hvn_peering_identifier" {
  default = "lambdaConsul"
}

variable "consul_public_endpoint" {
  type    = bool
  default = true
}

variable "hcp_consul_tier" {
  type        = string
  description = "Pricing tier for HCP Consul"
  default     = "development"
}

variable "hcp_config" {
  type = object({
    aws_account_id             = string
    aws_default_route_table_id = string
    aws_region                 = string
    aws_vpc_cidr_block         = string
    aws_vpc_id                 = string
    private_route_table_ids    = list(string)
    public_route_table_ids     = list(string)
    identifier                 = string
  })
}