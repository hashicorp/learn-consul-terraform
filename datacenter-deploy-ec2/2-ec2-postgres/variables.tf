variable "name" {
  type        = string
  description = "Name"
  default     = "gs-consul-client"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "AWS CIDR block"
}

variable "subnet_id" {
  type        = string
  description = "AWS subnet (public)"
}

variable "consul_security_group" {
  type        = string
  description = "AWS Security group for Consul"
}

variable "consul_version" {
  type        = string
  description = "Consul server version"
  default     = "1.12.4"
}

variable "consul_bootstrap_token_secret_arn" {
  type        = string
  description = "Secret ARN for Consul bootstrap token"
}

variable "consul_server_ca_cert_arn" {
  type        = string
  description = "Secret ARN for Consul CA Cert"
}

variable "consul_gossip_key_arn" {
  type        = string
  description = "Secret ARN for Consul gossip key"
}

variable "consul_server_http_addr" {
  type        = string
  description = "Consul server HTTP address"
}

variable "keypair_name" {
  type        = string
  description = "AWS keypair name"
  default     = "gs-consul-client-consul-client"
}