# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_availability_zones" "azs_no_local_zones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
  state = "available"
}

# Creates all the constant values and pre-rendered practitioner files.
module "render_tutorial" {
  source = "./modules/rendering"
}

# Deploy AWS and VPC resources
module "infrastructure" {
  source = "./modules/infra"

  cluster_id             = module.render_tutorial.tutorial_outputs.hcp_cluster_id
  hvn_id                 = module.render_tutorial.tutorial_outputs.hvn_id
  hvn_region             = module.render_tutorial.tutorial_outputs.region
  vpc_region             = module.render_tutorial.tutorial_outputs.region
  lambda_payments_name   = module.render_tutorial.tutorial_outputs.lambda_payments_name
  vpc_id                 = module.render_tutorial.tutorial_outputs.vpc_id
  aws_availability_zones = data.aws_availability_zones.azs_no_local_zones.names
}

# Deploys Kubernetes resources
module "eks_consul_client" {
  source = "./modules/eks-client"

  hcp_cluster_id        = module.render_tutorial.tutorial_outputs.hcp_cluster_id
  consul_hosts          = module.infrastructure.eks_consul_client_values.consul_hosts
  k8s_api_endpoint      = module.infrastructure.eks_consul_client_values.eks_cluster_endpoint
  consul_version        = module.infrastructure.eks_consul_client_values.consul_version
  boostrap_acl_token    = module.infrastructure.eks_consul_client_values.bootstrap_acl_token
  consul_ca_file        = module.infrastructure.eks_consul_client_values.consul_ca_file
  datacenter            = module.infrastructure.eks_consul_client_values.datacenter
  gossip_encryption_key = module.infrastructure.eks_consul_client_values.gossip_encryption_key
  eks_cluster_id        = module.infrastructure.kubernetes_cluster_id
  region                = var.vpc_region
  security_group        = module.infrastructure.security_group
}


module "remove_kubernetes_backed_enis" {
  source = "github.com/webdog/terraform-kubernetes-delete-eni"
  vpc_id = module.infrastructure.vpc.vpc_id
  region = var.vpc_region
}
