output "consul_addr" {
  value = hcp_consul_cluster.main.consul_public_endpoint_url
}

output "consul_datacenter" {
  value = hcp_consul_cluster.main.datacenter
}

output "consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "kubernetes_cluster_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "region" {
  value = var.vpc_region
}

output "kubernetes_cluster_id" {
  value = module.eks.cluster_id
}

# Technically, this doesn't exist until the practitioner deploys. The lambda
# function's name is set by a local variable pre-determined in locals.tf.
output lambda_function_registrator_cloudwatch_logs_path {
  value = "/aws/lambda/${local.ecr_repository_name}"
}

output "vpc" {
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    hvn_cidr_block = var.hvn_cidr_block
  }
}

output "eks_update_kubeconfig_command" {
  value = "aws eks --region ${var.vpc_region} update-kubeconfig --name ${data.aws_eks_cluster.cluster.endpoint}"
}

