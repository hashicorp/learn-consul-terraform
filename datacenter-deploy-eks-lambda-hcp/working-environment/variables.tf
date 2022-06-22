variable "consul_ca" {
  type = string
  description = "Consul CA file"
}

variable "consul_http_token" {
  type = string
  description = "Consul HTTP Token"
}

variable "consul_config" {
  type = string
  description = "base64 encoded consul config file"
}

variable "consul_http_addr" {
  type = string
  description = "Consul endpoint"
}

variable "kube_cluster_endpoint" {
  type = string
  description = "Kubernetes endpoint"
}

variable "consul_accessor_id" {
  type = string
  description = "Consul Accessor ID"
}

variable "consul_secret_id" {
  type = string
  description = "Consul secret ID"
}

variable "pod_replicas" {
  type = string
  default = "1"
}

variable "pod_name" {
  type = string
  description = "Name of tutorial working environment"
  default = "tutorial"
}

variable "kube_context" {
  type = string
  description = "Kube context"
}

variable "profile_name" {
  type = string
  description = "Profile name for AWS credentials"
}

variable "role_arn" {
  type = string
  description = "ARN for IAM Role"
}

variable "cluster_name" {
  type = string
  description = "Name of EKS cluster."
}

variable "cluster_region" {
  type = string
  description = "Region of EKS cluster."
}

variable "cluster_service_account_name" {
  type = string
  description = "Service account name for the Pod"
}

variable "gossip_key" {}

variable "consul_datacenter" {}
variable "kube_cluster_ca" {}