locals {
  consul_resources_path       =  "./modules/eks-client/hashicups/consul_resources/*"
  secret_name                 = "${var.hcp_cluster_id}"
}
