module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name             = var.vpc_id
  cidr             = var.vpc_cidr.cidr_block
  azs              = var.aws_availability_zones
  public_subnets   = var.vpc_cidr.public_subnets
  private_subnets =  var.vpc_cidr.private_subnets
  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "eks" {
  source          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version         = "18.23.0"
  cluster_name    = var.cluster_id
  cluster_version = var.kubernetes_version
  subnet_ids      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default_group = {
      min_size     = 3
      max_size     = 3
      desired_size = 3
      labels       = {}

      instance_types = ["t3a.medium"]
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
    egress_nodes_ephemeral_ports_udp = {
      description                = "To node 1025-65535"
      protocol                   = "udp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress = {
      description = "To node 1025-65535"
      protocol    = "-1"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_self_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      self             = true
    }
    egress = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }


  }
}

module "aws_hcp_consul" {
  source  = "registry.terraform.io/hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = hcp_hvn.main
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  route_table_ids    = concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)
  security_group_ids = [module.eks.cluster_primary_security_group_id]
  depends_on = [module.eks, module.vpc, hcp_hvn.main]
}

resource "hcp_hvn" "main" {
  cloud_provider = "aws"
  hvn_id         =  var.hvn_id
  cidr_block     =  var.hvn_cidr_block
  region         =  var.vpc_region
}

resource "hcp_consul_cluster" "main" {
  hvn_id             = hcp_hvn.main.hvn_id
  cluster_id         = var.cluster_id
  tier               = var.consul_tier
  min_consul_version = var.consul_version
  public_endpoint    = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

resource "aws_iam_role_policy_attachment" "main-additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.call_lambda.arn
  role       = each.value.iam_role_name
}

resource "aws_iam_policy" "call_lambda" {
  name        = var.lambda_payments_name
  path        = var.eks_iam_path
  description = "Permits invocation of any lambda function"
  policy = file("${path.module}/assets/iam-lambda_invoke_policy.json")
}




