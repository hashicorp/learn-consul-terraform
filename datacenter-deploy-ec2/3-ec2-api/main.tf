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

# resource "tls_private_key" "client" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

// Key pair
# resource "aws_key_pair" "consul_client" {
#   key_name   = "${var.name}-consul-client"
#   public_key = tls_private_key.client.public_key_openssh
# }

# data "aws_key_pair" "consul_client" {
#   key_name = var.keypair_name
# }

// Security groups
# resource "aws_security_group" "allow_ssh_egress" {
#   name        = "allow_ssh_egress"
#   description = "Allow SSH inbound and all egress traffic"
#   vpc_id      = data.aws_vpc.selected.id

# ingress {
#   description = "SSH into instance"
#   from_port   = 22
#   to_port     = 22
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# egress {
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }

#   tags = {
#     Name = "allow_ssh"
#   }
# }

resource "aws_security_group" "allow_api" {
  name        = "allow_api"
  description = "Allow port for api"
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

  ingress {
    description = "Public API port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Product API port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_api"
  }
}

// NGINX instance
resource "aws_instance" "hashicups_api" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow_api.id,
    # aws_security_group.allow_80.id
  ]
  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.name
  key_name             = var.keypair_name

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    setup = base64gzip(templatefile("${path.module}/scripts/setup.sh", {
      consul_ca       = base64encode(data.aws_secretsmanager_secret_version.ca_cert.secret_string),
      bootstrap_token = data.aws_secretsmanager_secret_version.bootstrap_token.secret_string,
      gossip_key      = data.aws_secretsmanager_secret_version.gossip_key.secret_string,
      consul_version  = var.consul_version,
      consul_cmd  = "/usr/bin/consul agent -data-dir /var/consul -config-dir=/etc/consul.d/",

      postgres_version = 11
      postgres_host = var.postgres_host
      postgres_port = 5432
      product_api_version = "0.0.22"
      public_api_version = "0.0.7"
      vpc_cidr         = var.vpc_cidr_block
    })),
  })

  tags = {
    Name = "hashicups-api"
  }
}
