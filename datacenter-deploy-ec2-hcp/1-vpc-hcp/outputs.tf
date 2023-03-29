# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "AWS VPC ID"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "AWS VPC CIDR block"
}

output "subnet_id" {
  value       = module.vpc.public_subnets[0]
  description = "AWS public subnet"
}

output "hcp_consul_cluster_id" {
  value       = hcp_consul_cluster.main.cluster_id
  description = "HCP Consul ID"
}

output "hcp_consul_security_group" {
  value       = module.aws_hcp_consul.security_group_id
  description = "AWS Security group for HCP Consul"
}
