output "consul_values" {
  value = {
    cert       = module.hcp-tutorial-deployment.ca_certificate_file
    gossip     = module.hcp-tutorial-deployment.consul_gossip_key
    root_token = module.hcp-tutorial-deployment.consul_bootstrap_token
    endpoint   = module.hcp-tutorial-deployment.hcp_consul_endpoint
    kube       = module.aws-tutorial-deployment.kubernetes_control_plane
  }
  sensitive = true
}

output "eks_cluster_name" {
  description = "EKS cluster ID."
  value       = module.aws-tutorial-deployment.eks_cluster_name
}

output "aws_region" {
  description = "AWS region"
  value       = module.aws-tutorial-deployment.aws_region
}
