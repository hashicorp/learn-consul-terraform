locals {
  unique_cluster_name = var.resource_config.aws_eks_cluster_name
  unique_policy_name= "${var.policy_name}-${var.resource_config.identifier}"
}

module "eks" {
  source                          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version                         = ">=18.9.0"
  cluster_name                    = local.unique_cluster_name
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

  vpc_id     = var.resource_config.aws_vpc_id
  subnet_ids = setunion(
    var.resource_config.aws_public_subnets,
    var.resource_config.aws_private_subnets
  )

  eks_managed_node_group_defaults = {
    ami_type               = var.eks_nodes_ami
    disk_size              = var.eks_node_disk_size
    instance_types         = [var.eks_instance_type]
    vpc_security_group_ids = var.resource_config.aws_security_group_ids
    vpc_security_group_ids = [aws_security_group.open.id, aws_security_group.hashicups_kubernetes.id]
  }

  eks_managed_node_groups = {
    standard = {
      min_size     = var.eks_min_instances
      max_size     = var.eks_max_instances
      desired_size = var.eks_desired_instances
    }
  }
  tags = {
    Environment = var.eks_cluster_stage
  }
}

module "iam_role_for_service_accounts" {
  source    = "registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = lower(local.unique_cluster_name)
  version   = "4.14.0"

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.kube_namespace}:${var.kube_service_account_name}"]
    }
  }
}

