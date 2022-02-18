variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "consul-eks"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "hcp_datacenter_name" {
  type = string
  description = "The name of datacenter the Consul cluster belongs to"
  default = "dc1"
}

variable "default_tags" {
  description = "Default Tags for AWS"
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "Education-Consul"
    tutorial    = "Serverless Consul service mesh with EKS and HCP"
  }
}

variable "datacenter_name" {
  default = "hcp-dc1"
  description = "Name of the Consul datacenter to create"
}

variable "output_dir" {
  default = "."
  description = "The directory to store output artifacts like kubeconfig files"
}