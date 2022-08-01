data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name                       = var.vpc_id
  cidr                       = var.vpc_cidr.cidr_block
  azs                        = var.aws_availability_zones
  public_subnets             = var.vpc_cidr.public_subnets
  private_subnets            = var.vpc_cidr.private_subnets
  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }
  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  enable_dns_support         = true
}

output "security_group" {
  value = aws_security_group.hashicups_kubernetes.id
}

# A Security Group for the HashiCups deployment.
resource "aws_security_group" "hashicups_kubernetes" {
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

module "eks" {
  source          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = var.cluster_id
  cluster_version = var.kubernetes_version
  subnet_ids      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = false
  eks_managed_node_group_defaults = {

  }
  create_cluster_security_group = false
  cluster_security_group_id     = aws_security_group.hashicups_kubernetes.id
  eks_managed_node_groups = {
    default_group = {
      min_size               = 3
      max_size               = 3
      desired_size           = 3
      labels                 = {}
      vpc_security_group_ids = [aws_security_group.hashicups_kubernetes.id]

      instance_types = ["m5.large"]
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }
}

resource "hcp_hvn" "main" {
  cloud_provider = "aws"
  hvn_id         = var.hvn_id
  cidr_block     = var.hvn_cidr_block
  region         = var.vpc_region
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
  policy      = file("${path.module}/assets/iam-lambda_invoke_policy.json")
}

locals {
  peering_id = var.vpc_id
}

resource "hcp_aws_network_peering" "default" {
  peer_account_id = data.aws_caller_identity.current.account_id
  peering_id      = var.vpc_id
  peer_vpc_region = var.vpc_region
  peer_vpc_id     = module.vpc.vpc_id
  hvn_id          = hcp_hvn.main.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route" {
  hvn_route_id     = "${var.vpc_id}-route"
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

