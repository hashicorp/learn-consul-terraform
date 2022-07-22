locals {
  consul_resources_path_service_defaults   = "./modules/eks-client/hashicups/consul_resources/service-defaults/*"
  consul_resources_path_service-intentions = "./modules/eks-client/hashicups/consul_resources/service-intentions/*"
  consul_resources_path                    = "./modules/eks-client/hashicups/consul_resources/*"
  kube_resources_path_service-accounts     = "./modules/eks-client/hashicups/kube_resources/service-account/*"
  kube_resources_path_config-maps          = "./modules/eks-client/hashicups/kube_resources/config-map/*"
  hashicups_resources                      = "./modules/eks-client/hashicups/**"
  service_account_config_maps              = setunion(fileset(path.root, local.kube_resources_path_service-accounts), fileset(path.root, local.kube_resources_path_config-maps))
  service_intentions                       = fileset(path.root, local.consul_resources_path_service-intentions)
  service_defaults                         = fileset(path.root, local.consul_resources_path_service_defaults)
  proxy_defaults                           = fileset(path.root, local.consul_resources_path)
  consul_yamls                             = setunion(local.service_intentions, local.service_defaults, local.proxy_defaults)
  secret_name                              = var.hcp_cluster_id
}
