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
