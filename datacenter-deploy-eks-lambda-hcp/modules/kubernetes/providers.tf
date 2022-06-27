terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.8.2"
    }
  }
}


provider "kubernetes" {
  host                   = var.kube_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kube_cluster_ca)
  config_path            = var.kubeconfig
  config_context         = var.kube_ctx_alias
}

provider "kustomization" {
  context         = var.kube_ctx_alias
  kubeconfig_path = var.kubeconfig
}