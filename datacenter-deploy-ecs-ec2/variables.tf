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

variable "ssh_keypair_name" {
  description = "Name of the SSH keypair to use in AWS."
  type        = string
  default     = null
}

#variable "ssh_keypair_path" {
#  description = "Path to the private portion of the SSH key specified."
#  default     = null
#}

variable "tls" {
  description = "Whether to enable TLS on the server for the control plane traffic."
  type        = bool
  default     = true
}

variable "gossip_key_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the Consul gossip encryption key."
  type        = string
  default     = ""
}

variable "acls" {
  description = "Whether to enable ACLs on the server."
  type        = bool
  default     = true
}

variable "suffix" {
  type        = string
  default     = "nosuffix"
  description = "Suffix to add to all resource names."
}

variable "secure" {
  description = "Whether to create all resources in a secure installation (with TLS, ACLs and gossip encryption)."
  type        = bool
  default     = true
}

variable "consul_version" {
  description = "Consul server version"
  type        = string
  default     = "1.10.2"
}