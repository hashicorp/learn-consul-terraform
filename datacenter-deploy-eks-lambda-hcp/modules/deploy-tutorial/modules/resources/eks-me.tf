# Deploys Amazon EKS
module "eks" {
  # Full URL due to this issue: https://github.com/VladRassokhin/intellij-hcl/issues/365
  source                          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version                         = ">=18.9.0"
  cluster_name                    = local.cluster_name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true


  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id = data.aws_vpc.this.id
  subnet_ids = setunion(
    var.aws_config.public_subnets,
    var.aws_config.private_subnets
  )

  # Node Groups
  eks_managed_node_group_defaults = {
    ami_type               = var.eks_nodes_ami
    disk_size              = var.node_disk_size
    instance_types         = [var.instance_type]
    vpc_security_group_ids = var.aws_config.security_group_ids
    vpc_security_group_ids = [aws_security_group.open.id, aws_security_group.hashicups_kubernetes.id]
  }

  eks_managed_node_groups = {
    standard = {
      min_size     = var.min_instances
      max_size     = var.max_instances
      desired_size = var.desired_instances
    }
  }
  tags = {
    Environment = var.cluster_stage
  }
}