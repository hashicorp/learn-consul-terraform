variable "cluster_networking" {
  type        = any
  description = "VPC settings for this tutorial's EKS Cluster"
  default = {
    vpc = {
      name            = "vpcClusterForLambdaFuncTutorial"
      cidr_block      = "172.16.0.0/16"
      private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
      public_subnets  = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
    },
  }
}

variable "cluster_definitions" {
  description = "Additional EKS cluster configuration settings to pass to EKS module"
  default = {
    name              = "eksLambConsul"
    min_instances     = 3
    max_instances     = 3
    desired_instances = 3
    node_disk_size    = 50
    ami               = "AL2_x86_64"
    instance_type     = "m5.large"
    service_account_name = "tutorial"
  }
}

variable "api_gateway_version" {
  default = "0.2.1"
}

variable "consul_image" {
  default = "hashicorp/consul:1.12.2"
}

# These are the variables we receive from upstream
variable "tutorial_config" {
  type = object({
    aws_account_id              = string
    aws_region                  = string
    random_identifier           = string
    aws_vpc_cidr_block          = string
    public_subnets              = list(string)
    private_subnets             = list(string)
    hcp_datacenter              = string
    hcp_cloud_provider          = string
    hcp_consul_tier             = string
    vpc_name                    = string
    eks_cluster_name        = string
    aws_profile_name        = string
    hcp_hvn_cidr_block      = string
    hvn_peering_identifier  = string
    eks_cluster_stage       = string
    hcp_hvn                 = string
    kubeconfig              = string
    kube_ctx_alias          = string
  })
  description = "Object definition for tutorial configuration."
}
