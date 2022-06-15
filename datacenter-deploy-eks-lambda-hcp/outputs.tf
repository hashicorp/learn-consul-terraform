# output "consul_values" {
#   value     = module.tutorial_infrastructure.consul_values
#   sensitive = true
# }

output "consul_url" {
  value     = module.tutorial_infrastructure.consul_values.public_endpoint
  sensitive = true
}

output "consul_root_token" {
  value     = module.tutorial_infrastructure.consul_values.root_token
  sensitive = true
}

output "eks_cluster_name" {
  description = "EKS cluster ID."
  value       = module.tutorial_infrastructure.eks_cluster_name
}

output "aws_region" {
  description = "AWS region"
  value       = module.tutorial_infrastructure.aws_region
}
