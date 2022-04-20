module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name                 = local.unique_vpc
  azs                  = local.vpc_azs
  cidr                 = var.cluster_cidrs.ecs_cluster.cidr_block
  private_subnets      = var.cluster_cidrs.ecs_cluster.private_subnets
  public_subnets       = var.cluster_cidrs.ecs_cluster.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

