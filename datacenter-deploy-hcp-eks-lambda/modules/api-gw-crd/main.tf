terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

variable "crd_path" {
  type        = string
  description = "Where CRDs for the API Gateway are located"
  default     = "./modules/eks-client/api-gw/crd/*.yaml"
}

resource "kubectl_manifest" "consul_api_gateway" {
  for_each  = fileset(path.root, var.crd_path)
  yaml_body = file(each.value)
}

