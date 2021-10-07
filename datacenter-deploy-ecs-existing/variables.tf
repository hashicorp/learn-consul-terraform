variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "consul-ecs"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "lb_ingress_ip" {
  description = "Your Public IP. This is used in the load balancer security groups to ensure only you can access the Consul UI and example application."
  type        = string
}


variable "hcp_client_id" {
  description = "HCP Client ID."
  type        = string
}

variable "hcp_client_secret" {
  description = "HCP Client Secret."
  type        = string
}

variable "vpc_id" {
  type = string
  description = "The VPC ID"
}

variable "consul-acl-token" {
  type = string
  description = "The Consul ACL token to use"
}

variable "consul-gossip-key" {
  type = string
  description = "The Consul gossip key"
}

variable "consul-client-ca" {
  type = string
  description = "The Consul CA value"
}

variable "public-subnets-ids" {
  type = list(string)
  description = "A list of public subnets and their respective id"
}