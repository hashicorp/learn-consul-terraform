terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.0.0"
    }
    kustomization = {
      source = "kbst/kustomize"
      version = "0.2.0-beta.3"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kustomization" {}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = local.unique_kube_cluster_name
}