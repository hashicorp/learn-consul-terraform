#terraform {
#  required_providers {
#    kubectl = {
#      source  = "gavinbunney/kubectl"
#      version = "1.14.0"
#    }
#  }
#}
#
#data "aws_eks_cluster" "this" {
#  name = module.eks.cluster_id
#}
#
#provider "kubectl" {
#  # Configuration options
#  host                   = data.aws_eks_cluster.this.endpoint
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#  load_config_file       = false
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    command = "aws"
#    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id ]
#  }
#}
#
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.this.endpoint
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    command     = "aws"
#    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#  }
#}
