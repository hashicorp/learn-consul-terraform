variable "aws_region" {
  type        = string
  description = "AWS region to deploy terraform resources"
  default     = "us-west-2"
}

variable "tutorial_networking" {
  type        = any
  description = "VPC settings for the EKS Cluster"
  default = {
    hcp_cloud_provider = "aws"
    hcp_hvn = "lambdaConsul"
    hcp_hvn_cidr_block = "172.25.16.0/20"
    hvn_peering_identifier = "lambdaConsul"
    vpc = {
      name            = "vpc-lambdaConsul"
      cidr_block      = "172.16.0.0/16"
      private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
      public_subnets  = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
    },
  }
}

variable "eks_cluster_configuration" {
  description = "Cluster definitions for EKS"
  type = any
  default = {
    name = "learn-consul-lambda"
    stage = "dev"
  }
}

variable "hcp_consul_tier" {
  default = "development"
}

variable "kubeconfig" {
  default = "tutorial_config"
}

variable "kube_ctx_alias" {
  default = "lambdaTutorial"
}

variable "aws_profile_name" {
  default = "default"
}