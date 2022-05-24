data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}


data "terraform_remote_state" "hcp" {
  backend = "local"

  config = {
    path = "../2-hcp/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

// Key pair
resource "aws_key_pair" "consul_client" {
  key_name   = "consul_client"
  public_key = file("consul-client.pub")
}

// Security groups
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

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

// Consul client instance
resource "aws_instance" "consul_client" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [
    data.module.hcp.hcp_consul_security_group_id,
    aws_security_group.allow_ssh.id
  ]
  key_name = aws_key_pair.consul_client.key_name

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    setup = base64gzip(templatefile("${path.module}/templates/setup.sh", {
      consul_config    = var.client_config_file,
      consul_ca        = var.client_ca_file,
      consul_acl_token = var.root_token,
      consul_version   = var.consul_version,
      consul_service = base64encode(templatefile("${path.module}/templates/service", {
        service_name = "consul",
        service_cmd  = "/usr/bin/consul agent -data-dir /var/consul -config-dir=/etc/consul.d/",
      })),
    })),
  })

  tags = {
    Name = "${random_id.id.dec}-hcp-nomad-host"
  }

  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }
}
