terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.8.2"
    }
    aws = {
      source = "hashicorp/aws"
      version = ">3.0.0"
    }
  }
}

provider "aws" {
  region = var.cluster_region
}

provider "kubernetes" {
  host                   = var.kube_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kube_cluster_ca)
  config_path = var.kubeconfig
}

provider "kustomization" {
  context = var.cluster_name
  kubeconfig_path = var.kubeconfig
}