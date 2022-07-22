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
  version         = "18.24.1"
  cluster_name    = var.cluster_id
  cluster_version = var.kubernetes_version
  subnet_ids      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id
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

      instance_types = ["t3a.medium"]
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
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
  depends_on         = [module.eks, module.vpc, hcp_hvn.main]
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

