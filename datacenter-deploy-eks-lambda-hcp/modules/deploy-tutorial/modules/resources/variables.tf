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

variable "policy_name" {
  type        = string
  description = "Name of the IAM Policy"
  default = "tutorial-lambda-service-account"
}

variable "description" {
  type        = string
  description = "Policy description"
  default = "IAM Policy for Kubernetes Service Account"
}

variable "local_policy_file_path" {
  type        = string
  description = "The path of the local policy file in this module"
  default     = "iam_policies/iam_policy.json.tftpl"
}

variable "kube_namespace" {
  type = string
  description = "Which namespace to work in, for this tutorial"
  default = "default"
}

variable "kube_service_account_name" {
  type = string
  description = "Service Account for the working environment"
  default = "lambda-consul"
}