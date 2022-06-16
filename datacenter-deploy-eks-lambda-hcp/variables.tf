variable "aws_region" {
  type        = string
  description = "AWS region to deploy terraform resources"
  default     = "us-east-1"
}

variable "hvn_settings" {
  type        = any
  description = "Settings for the HCP HVN"
  default = {
    name = {
      main-hvn = "main-hvn"
    }
    cloud_provider = {
      aws = "aws"
    }
    region = {
      us-east-1 = "us-east-1"
    }
    cidr_block = "172.25.16.0/20"
  }
}

variable "cluster_networking" {
  type        = map(any)
  description = "VPC settings for this tutorial's EKS Cluster"
  default = {
    vpc = {
      name            = "vpcClusterForLambdaFuncTutorial"
      cidr_block      = "172.16.0.0/16"
      private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
      public_subnets  = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
    },
  }
}

variable "cluster_definitions" {
  description = "Cluster definitions for EKS"
  type        = map(any)
  default = {

    name = "learn-consul-lambda"
  }
}
