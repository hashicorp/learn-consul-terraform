module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name             = local.vpc_id
  cidr             = var.vpc_cidr.cidr_block
  azs              = data.aws_availability_zones.available.names
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
  cluster_name    = local.cluster_id
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

module "aws_hcp_consul" {
  source  = "registry.terraform.io/hashicorp/hcp-consul/aws"
  version = "~> 0.6.1"

  hvn                = hcp_hvn.main
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  route_table_ids    = concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids)
  security_group_ids = [module.eks.cluster_primary_security_group_id]
  depends_on = [module.eks, module.vpc]
}

module "eks_consul_client" {
  source = "./modules/eks-client"

  cluster_id       = hcp_consul_cluster.main.cluster_id
  consul_hosts     = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["retry_join"]
  k8s_api_endpoint = module.eks.cluster_endpoint
  consul_version   = hcp_consul_cluster.main.consul_version
  boostrap_acl_token    = hcp_consul_cluster_root_token.token.secret_id
  consul_ca_file        = base64decode(hcp_consul_cluster.main.consul_ca_file)
  datacenter            = hcp_consul_cluster.main.datacenter
  gossip_encryption_key = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["encrypt"]
  gateway_crd           = data.kustomization.gateway_crds
  region                = var.vpc_region
    depends_on = [module.render_configs, module.vpc, module.aws_hcp_consul, module.eks] #module.vpc]
}


module "render_configs" {
  source               = "./modules/render_files"
  lambda_payments_name = local.lambda_payments_name
}

module "remove_kubernetes_backed_enis" {
  source = "github.com/webdog/terraform-kubernetes-delete-eni"
  vpc_id = module.vpc.vpc_id
  region = var.vpc_region
}

#resource "null_resource" "clean_kube" {
#  triggers = {
#    script_cmd   = local.script_cmd
#  }
#  provisioner "local-exec" {
#    when = destroy
#    command = self.triggers.script_cmd
#  }
#  lifecycle {
#    ignore_changes = all
#
#  }
#}