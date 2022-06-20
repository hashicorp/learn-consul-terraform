# Create shared VPC between AWS and HCP
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name                 = var.tutorial_config.vpc_name
  azs                  = local.vpc_azs
  cidr                 = var.cluster_networking.vpc.cidr_block
  private_subnets      = var.cluster_networking.vpc.private_subnets
  public_subnets       = var.cluster_networking.vpc.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "resources" {
  source               = "./modules/resources"
  resource_config      = local.resource_config
}

module "remove_eni" {
  source = "github.com/webdog/terraform-kubernetes-delete-eni"
  vpc_id = module.vpc.vpc_id
  region = var.tutorial_config.aws_region
}

resource "local_file" "consul_k8s_values" {
  content = templatefile("${path.root}/modules/kubernetes/template_scripts/values.yaml.tftpl", {
    #https://
    CONSUL_PRIVATE_ENDPOINT = substr(module.resources.resources.consul_http_addr, 8, -1)
    CONSUL_DATACENTER       = local.resource_config.hcp_consul_datacenter
    CONSUL_IMAGE            = var.consul_image
    KUBE_CONTROL_PLANE      = module.resources.resources.kube_cluster_endpoint
  })
  filename = "${path.root}/working-environment/rendered/values.yaml"
}

resource "local_file" "kubernetes_tfvars" {
  filename = "${path.root}/working-environment/terraform.tfvars"
  content  = <<CONFIGURATION
consul_accessor_id="${module.resources.resources.consul_root_token_accessor_id}"
consul_ca="${module.resources.resources.consul_ca}"
consul_config="${module.resources.resources.consul_config}"
consul_http_addr="${module.resources.resources.consul_http_addr}"
consul_http_token="${module.resources.resources.consul_http_token}"
kube_cluster_endpoint="${module.resources.resources.kube_cluster_endpoint}"
profile_name="${var.tutorial_config.aws_profile_name}"
cluster_service_account_name="${var.cluster_definitions.service_account_name}"
cluster_name="${var.tutorial_config.eks_cluster_name}"
cluster_region="${var.tutorial_config.aws_region}"
CONFIGURATION
}