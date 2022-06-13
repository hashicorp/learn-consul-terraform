variable "lambda_name" {}

variable "region" {}

variable "consul_ca_cert" {}

variable "kubernetes_control_plane" {}

variable "private_subnets" {}

variable "security_groups" {
  type = list(string)
}

variable "aws_account_id" {}

variable "lambda_config" {
  type = object({
    aws_account_id           = string
    consul_ca_cert           = string
    kubernetes_control_plane = string
    private_subnets          = list(string)
    region                   = string
    security_groups          = list(string)
    identifier               = string
  })
}

variable "ecr_config" {
  type = object({
    public_ecr_region   = string
    ecr_base_image      = string
    ecr_repository_name = string
    ecr_image_tag       = string
  })

  default = {
    public_ecr_region   = "us-east-1"
    ecr_base_image      = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-alpha2"
    ecr_repository_name = "lambda_registrator"
    ecr_image_tag       = "0.1.0-alpha2"
  }
}