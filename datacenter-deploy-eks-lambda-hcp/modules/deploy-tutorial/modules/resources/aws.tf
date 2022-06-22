# Create routes for HCP Peering to the private routing table
resource "aws_route" "hcp_peering_private" {
  count                     = length(var.resource_config.aws_private_route_table_ids)
  route_table_id            = var.resource_config.aws_private_route_table_ids[count.index]
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  destination_cidr_block    = var.resource_config.hcp_hvn_cidr_block
}

# Create an AWS Route to the default route table for the HCP Peer
resource "aws_route" "peering-public-default" {
  route_table_id            = var.resource_config.aws_default_route_table_id
  destination_cidr_block    = var.resource_config.hcp_hvn_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

# Create routes for HCP Peering to the public route table.
resource "aws_route" "hcp_peering_public" {
  count                     = length(var.resource_config.aws_public_route_table_ids)
  route_table_id            = var.resource_config.aws_public_route_table_ids[count.index]
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  destination_cidr_block    = var.resource_config.hcp_hvn_cidr_block
}

# Create an accepter from the hcp_aws_network_peering pcx-id
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

# Security Group created for the AWS VPC. This eventually holds the settings for peering between HCP and AWS.
resource "aws_security_group" "open" {
  vpc_id = var.resource_config.aws_vpc_id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self      = true
  }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

}

# A Security Group for the HashiCups deployment.
resource "aws_security_group" "hashicups_kubernetes" {
  vpc_id = var.resource_config.aws_vpc_id

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

# Creates the IAM Policy for the EKS Cluster to describe itself and assume IAM Roles
resource "aws_iam_policy" "eks_cluster_describe_and_assume" {
  name = var.policy_name
  policy = templatefile("${path.module}/${var.local_policy_file_path}", {
    cluster_arn = module.eks.cluster_arn
  })
}

# Attached the policy above to a passed role name
resource "aws_iam_role_policy_attachment" "serviceAccountPolicyAttach" {
  policy_arn = aws_iam_policy.eks_cluster_describe_and_assume.arn
  role       = module.iam_role_for_service_accounts.iam_role_name
}