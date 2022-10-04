variable "cluster_id" {
  type        = string
  description = "The name of your HCP Consul cluster"
}

variable "lambda_payments_name" {
  description = "Name of Lambda function"
  type        = string
}

variable "eks_iam_path" {
  description = "Path in IAM"
  default     = "/eks/"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "vpc_region" {
  type        = string
  description = "The AWS region to create resources in"
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "AZs for this tutorial"
}

variable "hvn_region" {
  type        = string
  description = "The HCP region to create resources in"
}

variable "hvn_id" {
  type        = string
  description = "The name of your HCP HVN"
}

variable "consul_tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "standard"
}

variable "consul_version" {
  type        = string
  description = "The HCP Consul version"
  default     = "v1.12.5"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes to deploy to EKS"
  default     = "1.22"
}

variable "vpc_cidr" {
  type        = any
  description = "VPC configuration"
  default = {
    cidr_block      = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]
  }
}

variable "hvn_cidr_block" {
  type        = string
  description = "The CIDR range to create the HCP HVN with"
  default     = "172.25.32.0/20"
}