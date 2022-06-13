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
  type        = any
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
  description = "Additional EKS cluster configuration settings to pass to EKS module"
  default = {
    name              = "eksLambConsul"
    min_instances     = 3
    max_instances     = 3
    desired_instances = 3
    node_disk_size    = 50
    ami               = "AL2_x86_64"
    instance_type     = "m5.large"
  }
}

variable "tutorial_config" {
  type = object({
    aws_vpc_cidr_block          = string
    default_route_table_id      = string
    vpc_private_route_table_ids = list(string)
    vpc_public_route_table_ids  = list(string)
    aws_account_id              = string
    private_subnets             = list(string)
    public_subnets              = list(string)
    security_group_ids          = list(string)
    vpc_id                      = string
    consul_enterprise_license   = string
    aws_region                  = string
    identifier                  = string
  })
  description = "Object definition for tutorial config passed downstream to modules"
}


variable "hcp_cloud_provider" {
  type        = string
  description = "Cloud Provider for HCP"
  default     = "aws"
}

variable "consul_cluster_datacenter" {
  type        = string
  description = "Datacenter name"
  default     = "dc1"
}