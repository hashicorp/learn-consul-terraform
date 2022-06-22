terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
}

provider "kubernetes" {
  host                   = var.kube_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kube_cluster_ca)
  config_path = "~/.kube/config"
}