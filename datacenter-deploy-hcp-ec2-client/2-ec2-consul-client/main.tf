locals {
  vpc_region = "us-west-2"
  hvn_region = "us-west-2"
  cluster_id = "learn-hcp-consul-ec2-client"
  hvn_id     = "learn-hcp-consul-ec2-client-hvn"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "hcp_hvn" "selected" {
  hvn_id = data.hcp_consul_cluster.selected.hvn_id
}

data "hcp_consul_cluster" "selected" {
  cluster_id = var.cluster_id
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = data.hcp_consul_cluster.selected.id
}

// EC2 instance
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

// Key pair
resource "aws_key_pair" "consul_client" {
  key_name   = "consul_client-tu"
  public_key = file("./consul-client.pub")
}

// Security groups
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  # vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_id = data.aws_vpc.selected.id

  ingress {
    description      = "SSH into instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

// Security groups
resource "aws_security_group" "hcp_consul" {
  name        = "hcp_consul"
  description = "HCP Consul security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Consul LAN Serf (tcp)"
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.hcp_hvn.selected.cidr_block]
  }

  ingress {
    description = "Consul LAN Serf (udp)"
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [data.hcp_hvn.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hcp_consul"
  }
}

// Consul client instance
resource "aws_instance" "consul_client" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.hcp_consul.id,
    aws_security_group.allow_ssh.id
  ]
  key_name = aws_key_pair.consul_client.key_name

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    setup = base64gzip(templatefile("${path.module}/scripts/setup.sh", {
      consul_ca        = data.hcp_consul_cluster.selected.consul_ca_file
      consul_config    = data.hcp_consul_cluster.selected.consul_config_file
      consul_acl_token = hcp_consul_cluster_root_token.token.secret_id,
      consul_version   = data.hcp_consul_cluster.selected.consul_version,
      consul_service = base64encode(templatefile("${path.module}/scripts/service", {
        service_name = "consul",
        service_cmd  = "/usr/bin/consul agent -data-dir /var/consul -config-dir=/etc/consul.d/",
      })),
      vpc_cidr = var.vpc_cidr_block
    })),
  })

  tags = {
    Name = "hcp-consul-client-${count.index}"
  }
}