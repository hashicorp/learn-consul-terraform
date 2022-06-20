terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
}

locals {
  kube_exec_token = ["eks", "get-token", "--cluster-name", var.kube_cluster_endpoint]
}

provider "kubernetes" {
  host                   = var.kube_cluster_endpoint
  cluster_ca_certificate = var.consul_ca
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = local.kube_exec_token
  }
}