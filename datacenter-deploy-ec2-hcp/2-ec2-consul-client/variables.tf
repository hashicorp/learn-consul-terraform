# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "AWS CIDR block"
}

variable "subnet_id" {
  type        = string
  description = "AWS subnet (public)"
}

variable "cluster_id" {
  type        = string
  description = "HCP Consul ID"
}

variable "hcp_consul_security_group_id" {
  type        = string
  description = "AWS Security group for HCP Consul"
}
