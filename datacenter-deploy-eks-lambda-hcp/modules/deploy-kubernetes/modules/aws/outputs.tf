output "kubernetes_control_plane" {
  value = module.eks.cluster_endpoint
}