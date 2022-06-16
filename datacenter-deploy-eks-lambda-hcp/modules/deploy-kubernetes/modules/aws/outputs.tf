output "kubernetes_control_plane" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_config.aws_region
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_oidc_issuer_url" {
  description = "EKS OIDC URL"
  value       = module.eks.cluster_oidc_issuer_url
}
