# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hcp_login_token" {
  value     = module.infrastructure.consul_token
  sensitive = true
}

output "kubernetes_cluster_endpoint" {
  value = module.infrastructure.kubernetes_cluster_endpoint
}

output "cloudwatch_logs_path" {
  value = {
    registrator = "/aws/lambda/${local.ecr_repository_name}"
    payments    = "/aws/lambda/${local.lambda_payments_name}"
    eks         = "/aws/eks/${module.render_tutorial.tutorial_outputs.vpc_id}/cluster"
  }
}

output "eks_update_kubeconfig_command" {
  value = module.infrastructure.eks_update_kubeconfig_command
}

output "region" {
  value = var.vpc_region
}

output "consul_addr" {

  value = module.infrastructure.consul_addr
}