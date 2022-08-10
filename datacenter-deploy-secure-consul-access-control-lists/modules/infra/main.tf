
locals {
  aws_subnets         = cidrsubnets(var.aws_cidr_block, 4, 4, 4, 4)
  aws_private_subnets = slice(local.aws_subnets, 0, 2)
  aws_public_subnets  = slice(local.aws_subnets, 2, length(local.aws_subnets))
  peering_id          = "${var.aws_vpc_id}-peering"
}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name                       = var.aws_vpc_id
  cidr                       = var.aws_cidr_block
  azs                        = var.aws_availability_zones
  public_subnets             = local.aws_public_subnets
  private_subnets            = local.aws_private_subnets
  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }
  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  enable_dns_support         = true
}

resource "tls_private_key" "consul" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename        = "./ec2.pem"
  content         = tls_private_key.consul.private_key_pem
  file_permission = "0400"
}

resource "aws_launch_template" "consul_ec2" {
  user_data = filebase64("${path.module}/user-data.sh")
}

resource "aws_key_pair" "consul" {
  public_key = tls_private_key.consul.public_key_openssh
}

resource "aws_security_group" "consul_ec2" {
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["216.80.1.157/32"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hcp_peering" {
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["172.25.0.0/16"]
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["172.25.0.0/16"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }
}

resource "aws_instance" "consul" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.consul.key_name
  vpc_security_group_ids      = [aws_security_group.consul_ec2.id, aws_security_group.hcp_peering.id]
  launch_template {
    name = aws_launch_template.consul_ec2.name
  }

}

resource "aws_security_group" "consul" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

}

resource "hcp_hvn" "main" {
  cloud_provider = "aws"
  hvn_id         = var.hvn_id
  cidr_block     = var.hvn_cidr_block
  region         = var.region
}

resource "hcp_consul_cluster" "main" {
  hvn_id             = hcp_hvn.main.hvn_id
  cluster_id         = var.consul_cluster_id
  tier               = var.consul_tier
  min_consul_version = var.consul_version
  public_endpoint    = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

resource "hcp_aws_network_peering" "default" {
  peer_account_id = var.aws_account_id
  peering_id      = var.aws_vpc_id
  peer_vpc_region = var.region
  peer_vpc_id     = module.vpc.vpc_id
  hvn_id          = hcp_hvn.main.hvn_id
}


resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route" {
  hvn_route_id     = "${var.aws_vpc_id}-route"
  target_link      = hcp_aws_network_peering.default.self_link
  hvn_link         = hcp_hvn.main.self_link
  destination_cidr = module.vpc.vpc_cidr_block
  depends_on       = [aws_vpc_peering_connection_accepter.peer]

}

resource "aws_route" "public_to_hvn" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id            = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

resource "aws_route" "private_to_hvn" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

