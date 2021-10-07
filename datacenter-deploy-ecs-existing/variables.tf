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

variable "aws_access_key" {
  description = "AWS access key."
  type        = string
  default     = null
}

variable "aws_secret_key" {
  description = "AWS secret key."
  type        = string
  default     = null
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