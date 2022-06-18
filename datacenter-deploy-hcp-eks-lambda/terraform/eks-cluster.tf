data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "17.22.0"

#   cluster_name    = "${local.cluster_id}-eks"
#   cluster_version = "1.21"
#   subnets         = module.vpc.public_subnets
#   vpc_id          = module.vpc.vpc_id

#   node_groups = {
#     nodes = {
#       name_prefix      = "${local.cluster_id}-node"
#       instance_types   = ["t3a.medium"]
#       desired_capacity = 3
#       max_capacity     = 3
#       min_capacity     = 3
#     }
#   }
# }

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.23.0"
  cluster_name    = local.cluster_id
  cluster_version = "1.21"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

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

resource "aws_iam_policy" "call_lambda" {
  name        = "${local.cluster_id}-execution"
  path        = "/eks/"
  description = "${local.cluster_id} mesh-task execution policy"

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
