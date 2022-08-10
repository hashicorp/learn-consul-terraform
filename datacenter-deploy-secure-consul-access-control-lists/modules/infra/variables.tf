variable "aws_vpc_id" {
  description = "ID of AWS VPC"
  type        = string
}

variable "aws_cidr_block" {
  description = "CIDR Block for AWS VPC"
  type        = string
  default     = "10.130.0.0/16"
}

variable "aws_availability_zones" {
  description = "AZs for deployed VPC"
  type        = list(string)
}


variable "hvn_id" {
  description = "ID of the HashiCorp Virtual Network"
  type        = string
}

variable "hvn_cidr_block" {
  description = "CIDR block range for HVN"
  type        = string
  default     = "172.25.0.0/16"
}

variable "region" {
  description = "Shared region between HCP and AWS"
  type        = string
}

variable "consul_cluster_id" {
  description = "ID of HCP Consul Cluster"
  type        = string
}

variable "consul_tier" {
  description = "Type of HCP Consul cluster to deploy"
  type        = string
  default     = "development"
}

variable "consul_version" {
  description = "Version of Consul to deploy"
  type        = string
  default     = "1.12.2"
}

variable "ami_id" {
  description = "AMI ID for this tutorial"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}
