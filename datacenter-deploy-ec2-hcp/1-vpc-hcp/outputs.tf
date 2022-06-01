output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "subnet_id" {
  value = module.vpc.public_subnets[0]
}

output "hcp_consul_cluster_id" {
  value = hcp_consul_cluster.main.cluster_id
}

output "hcp_consul_security_group" {
  value = module.aws_hcp_consul.security_group_id
}
