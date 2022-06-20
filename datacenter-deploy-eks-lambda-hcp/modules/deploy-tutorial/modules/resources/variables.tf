locals {
  unique_hvn        = "${var.resource_config.hcp_hvn}-${var.resource_config.identifier}"
  unique_peering_id = "${var.resource_config.hvn_peering_identifier}-${var.resource_config.identifier}"
  unique_route_id   = "${local.unique_hvn}-route"
  raw_config        = jsondecode(base64decode(hcp_consul_cluster.server.consul_config_file))
  gossip_key        = local.raw_config["encrypt"]
}

variable "resource_config" {
  type = object({
    identifier                  = string
    aws_account_id              = string
    aws_default_route_table_id  = string
    aws_region                  = string
    aws_vpc_cidr_block          = string
    aws_vpc_id                  = string
    aws_eks_cluster_name        = string
    aws_cluster_stage           = string
    aws_private_route_table_ids = list(string)
    aws_public_route_table_ids  = list(string)
    aws_public_subnets          = list(string)
    aws_private_subnets         = list(string)
    aws_security_group_ids      = list(string)
    aws_profile_name            = string

    hcp_cloud_provider          = string
    hcp_consul_datacenter       = string
    hcp_consul_tier             = string
    #hcp_consul_bootstrap_token  = string
    #hcp_consul_ca_certificate   = string
    #hcp_consul_gossip_key       = string
    #hcp_datacenter              = string
    enable_hcp_consul_endpoint  = bool
    hcp_hvn                     = string
    hcp_hvn_cidr_block          = string
    hvn_peering_identifier      = string
  })
}

variable "enable_consul_public_endpoint" {
  type    = bool
  default = true
}

variable "eks_nodes_ami" {
  type        = string
  description = "AMI Type for EKS Nodes"
  default     = "AL2_x86_64"
}

variable "eks_node_disk_size" {
  type        = number
  description = "Disk Size in GB for an EKS Node"
  default     = 50
}

variable "eks_instance_type" {
  type        = string
  description = "Instance type for an EKS node"
  default     = "m5.large"
}

variable "eks_min_instances" {
  type        = number
  description = "Minimum number of EKS Nodes"
  default     = 3
}

variable "eks_max_instances" {
  type        = number
  description = "Maximum Number of EKS Nodes"
  default     = 3
}

variable "eks_desired_instances" {
  type        = number
  description = "Desired number of EKS Nodes"
  default     = 3
}

variable "eks_cluster_stage" {
  default = "dev"
}

#variable "hvn_name" {
#  default = "lambdaConsul"
#}
#
#variable "hcp_hvn_cidr_block" {
#  type        = string
#  description = "CIDR block for HCP"
#  default     = "172.25.16.0/20"
#}

#variable "hvn_peering_identifier" {
#  default = "lambdaConsul"
#}

#variable "kube_context" {
#  type        = string
#  description = "Kubeconfig context"
#  default     = "default"
#}

#variable "kubeconfig_path" {
#  type        = string
#  description = "Path to kubeconfig file"
#  default     = "~/.kube/config"
#}

#variable "shared_annotations" {
#  type        = map(string)
#  description = "Shared annotations by all containers"
#  default = {
#    "consul.hashicorp.com/connect-inject" = "true"
#  }
#}
#
#variable "shared_annotations_prometheus" {
#  type        = map(string)
#  description = "Support for prometheus"
#  default = {
#    "prometheus.io/scrape" = "true"
#    "prometheus.io/port"   = "9102"
#  }
#}

#variable "global_kube_resources" {
#  default = {
#    payments = {
#      has_volumes       = false
#      has_volume_mounts = false
#    }
#    public-api = {
#      has_volumes       = false
#      has_volume_mounts = false
#    }
#    product-api = {
#      has_volumes       = true
#      has_configmap     = true
#      has_volume_mounts = true
#    }
#    postgres = {
#      has_volumes       = true
#      has_configmap     = false
#      has_volume_mounts = true
#    }
#    frontend = {
#      has_volumes       = false
#      has_volume_mounts = false
#    }
#  }
#}

#variable "region" {
#  type = string
#  default = "us-west-2"
#}

#variable "kubernetes_service_account" {
#  type = string
#  default = "tutorial"
#}

#variable "profile_name" {
#  type = string
#  default = "tutorial"
#}

#variable "lambda_payments_path" {
#  type        = string
#  description = "Path to the HashiCups payments zip file for lambda"
#}

