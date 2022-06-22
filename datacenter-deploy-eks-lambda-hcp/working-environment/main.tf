# Creates the resources in Kubernetes for the reader to use their working environment
module "kubernetes_resources" {
  source = "../modules/kubernetes"

  cluster_service_account_name = var.cluster_service_account_name
  consul_accessor_id           = var.consul_accessor_id
  consul_ca                    = var.consul_ca
  consul_config                = var.consul_config
  consul_http_addr             = var.consul_http_addr
  consul_http_token            = var.consul_http_token
  consul_secret_id             = var.consul_secret_id
  kube_context                 = var.kube_context
  role_arn                     = var.role_arn
  profile_name                 = var.profile_name
  cluster_name                 = var.cluster_name
  cluster_region               = var.cluster_region
  consul_gossip_key            = var.gossip_key
  kube_cluster_endpoint        = var.kube_cluster_endpoint
  working-pod-service_account  = var.cluster_service_account_name
  working-pod-name             = var.pod_name
  consul_datacenter            = var.consul_datacenter
  kube_cluster_ca              = var.kube_cluster_ca
}