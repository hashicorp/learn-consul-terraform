variable "cluster_id" {
  type        = string
  description = "The name of your HCP Consul cluster"
  default     = "hcp-learn"
}

variable "vpc_region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "hvn_region" {
  type        = string
  description = "The HCP region to create resources in"
  default     = "us-east-1"
}

variable "hvn_id" {
  type        = string
  description = "The name of your HCP HVN"
  default     = "hcp-learn"
}

variable "hvn_cidr_block" {
  type        = string
  description = "The CIDR range to create the HCP HVN with"
  default     = "172.25.32.0/20"
}

variable "consul_tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "development"
}

variable "consul_version" {
  type        = string
  description = "The HCP Consul version"
  default     = "v1.12.2"
}

variable "kubernetes_version" {
  type = string
  description = "Version of Kubernetes to deploy to EKS"
  default = "1.22"
}

variable "api_gateway_version" {
  type        = string
  description = "The Consul API gateway CRD version to use"
  default     = "0.2.1"
}

variable "vpc_cidr" {
  type = any
  description = "VPC configruation"
  default = {
    cidr_block = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.4.0/24", "10.0.5.0/24"]
  }
}