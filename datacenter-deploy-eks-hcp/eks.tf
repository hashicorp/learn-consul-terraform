data "aws_vpc" "hvn_peer" {
  id = module.vpc.vpc_id
}

data "aws_subnet_ids" "hvn_peer" {
  vpc_id = module.vpc.vpc_id
}

#data "aws_subnet" "hvn_peer" {
#  for_each = data.aws_subnet_ids.hvn_peer.ids
#  id       = each.value
#}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.23.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  eks_managed_node_groups = {
    default_group = {
      min_size     = 3
      max_size     = 3
      desired_size = 3
      labels       = {}

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
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
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_from_cluster = {
      description = "To node 1025-65535"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "aws_iam_policy" "call_lambda" {
  name        = "${local.cluster_name}-execution"
  path        = "/ecs/"
  description = "${local.cluster_name} mesh-task execution policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.call_lambda.arn
  role       = each.value.iam_role_name
}
