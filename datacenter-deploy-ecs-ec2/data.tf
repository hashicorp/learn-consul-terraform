data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "this" {}

data "aws_caller_identity" "current" {}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "userdata" {
  #template = file("./scripts/cloud-init.yaml")
  template = file("./scripts/consul-server-init.sh")
  vars = {
    consul_acl_token = "${random_uuid.bootstrap_token.result}"
    consul_gossip_key = "${random_id.gossip_encryption_key.b64_std}"
    consul_ca_cert = "${tls_self_signed_cert.ca.cert_pem}"
    consul_version = var.consul_version
  }
}