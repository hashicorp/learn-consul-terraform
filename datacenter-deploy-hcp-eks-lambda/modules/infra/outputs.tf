output "vpc_subnets_lambda_registrator" {
  value = module.vpc.private_subnets
}

output "vpc_default_security_group" {
  value = module.vpc.default_security_group_id
}



output "consul_addr" {
  value = hcp_consul_cluster.main.consul_public_endpoint_url
}

output "eks_consul_client_values" {
  value = {
    hcp_cluster_id        = hcp_consul_cluster.main.cluster_id
    consul_hosts          = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["retry_join"]
    eks_cluster_endpoint  = module.eks.cluster_endpoint
    consul_version        = hcp_consul_cluster.main.consul_version
    bootstrap_acl_token   = hcp_consul_cluster_root_token.token.secret_id
    consul_ca_file        = base64decode(hcp_consul_cluster.main.consul_ca_file)
    datacenter            = hcp_consul_cluster.main.datacenter
    gossip_encryption_key = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["encrypt"]
    cluster_cert          = module.eks.cluster_certificate_authority_data
  }
}

output "consul_datacenter" {
  value = hcp_consul_cluster.main.datacenter
}

output "consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "kubernetes_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubernetes_cluster_id" {
  value = module.eks.cluster_id
}

output "region" {
  value = var.vpc_region
}

output "vpc" {
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    hvn_cidr_block = var.hvn_cidr_block
  }
}

output "eks_update_kubeconfig_command" {
  value = "aws eks --region ${var.vpc_region} update-kubeconfig --name ${module.eks.cluster_id}"
}

