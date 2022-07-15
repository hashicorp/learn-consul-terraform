resource "random_string" "cluster_id" {
  length  = 6
  special = false
  upper   = false
}

resource "hcp_hvn" "main" {
  hvn_id         = local.hvn_id
  region         = var.hvn_region
  cidr_block     = var.hvn_cidr_block
  cloud_provider = "aws"
}

resource "hcp_consul_cluster" "main" {
  hvn_id             = hcp_hvn.main.hvn_id
  cluster_id         = local.cluster_id
  tier               = var.consul_tier
  min_consul_version = var.consul_version
  public_endpoint    = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

resource "aws_iam_policy" "call_lambda" {
  name        = local.lambda_payments_name
  path        = local.iam_path
  description = "Allows invocation of Lambda functions"

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


