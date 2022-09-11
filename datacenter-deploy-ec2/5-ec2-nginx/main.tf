provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "selected" {
  id = var.subnet_id
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

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Key pair
resource "aws_key_pair" "consul_client" {
  key_name   = "${var.name}-consul-client"
  public_key = tls_private_key.client.public_key_openssh
}

// Security groups
resource "aws_security_group" "allow_ssh_egress" {
  name        = "allow_ssh_egress"
  description = "Allow SSH inbound and all egress traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH into instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_80" {
  name        = "allow_80"
  description = "Allow port 80 (NGNIX)"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "NGINX port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_80"
  }
}

// NGINX instance
resource "aws_instance" "hashicups_nginx" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow_ssh_egress.id,
    aws_security_group.allow_80.id
  ]
  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.name
  key_name = aws_key_pair.consul_client.key_name

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    setup = base64gzip(templatefile("${path.module}/scripts/setup.sh", {
      consul_ca        = base64encode(data.aws_secretsmanager_secret_version.ca_cert.secret_string),
      bootstrap_token = data.aws_secretsmanager_secret_version.bootstrap_token.secret_string,
      gossip_key = data.aws_secretsmanager_secret_version.gossip_key.secret_string,
      consul_version = var.consul_version,
      public_api_host = "${var.public_api_host}:8080"
      frontend_host = "${var.frontend_host}:4001"

      consul_cmd  = "/usr/bin/consul agent -data-dir /var/consul -config-dir=/etc/consul.d/",
      vpc_cidr = var.vpc_cidr_block
    })),
  })

  tags = {
    Name = "hashicups-nginx"
  }
}
