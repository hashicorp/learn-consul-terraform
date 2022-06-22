terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
#    kustomization = {
#        source = "kbst/kustomize"
#        version = "0.2.0-beta.3"
#    }
  }
}
#
##locals {
##  kube_exec_token = ["eks", "get-token", "--cluster-name", var.kube_cluster_endpoint]
##}
##
provider "kubernetes" {
  host                   = var.kube_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kube_cluster_ca)
  config_path = "~/.kube/config"
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    command     = "aws"
#    args        = ["eks", "get-token", "--cluster-name", var.kube_cluster_endpoint]
#  }
}

##data "aws_eks_cluster_auth" "cluster" {
##  name = var.cluster_name
##}
#
##locals {
##  # non-default context name to protect from using wrong kubeconfig
##  kubeconfig_context = "_terraform-kustomization-${var.cluster_name}_"
##
##  kubeconfig = {
##    apiVersion = "v1"
##    clusters = [
##      {
##        name = local.kubeconfig_context
##        cluster = {
##          certificate-authority-data = var.kube_cluster_ca#data.aws_eks_cluster.cluster.certificate_authority.0.data
##          server                     = var.kube_cluster_endpoint #data.aws_eks_cluster.cluster.endpoint
##        }
##      }
##    ]
##    users = [
##      {
##        name = local.kubeconfig_context
##        user = {
##          token = data.aws_eks_cluster_auth.cluster.token
##        }
##      }
##    ]
##    contexts = [
##      {
##        name = local.kubeconfig_context
##        context = {
##          cluster = local.kubeconfig_context
##          user    = local.kubeconfig_context
##        }
##      }
##    ]
##  }
##}
#
##provider "kustomization" {}
##
##data "kustomization" "gateway_crds" {
##  path = "github.com/hashicorp/consul-api-gateway/config/crd?ref=v${var.api_gateway_version}"
##}
##
##resource "kustomization_resource" "gateway_crds" {
##  for_each = data.kustomization.gateway_crds.ids
##  manifest = data.kustomization.gateway_crds.manifests[each.value]
##}
