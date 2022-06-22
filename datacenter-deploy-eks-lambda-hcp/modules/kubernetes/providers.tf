#terraform {
#  required_providers {
#    kubernetes = {
#      source = "hashicorp/kubernetes"
#      version = "2.8.0"
#    }
###    kustomization = {
###        source = "kbst/kustomize"
###        version = "0.2.0-beta.3"
###    }
##  }
#}

terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.5.0"
    }
  }
}

provider "kustomization" {
  context = var.cluster_name
  kubeconfig_path = "~/.kube/config"
}