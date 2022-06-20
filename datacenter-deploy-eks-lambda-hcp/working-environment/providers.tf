terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
}

provider "kubernetes" {
#  config_path = "~/.kube/config"
#  config_context = var.kube_context
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command = "aws"
    args = ["eks", "get-token", "--cluster-name", var.cluster_name ]
  }
}