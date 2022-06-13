module "eks-tutorial-deployment" {
  source     = "./modules/eks"
  eks_config = local.eks_config
}

module "hcp-tutorial-deployment" {
  source     = "./modules/hcp"
  hcp_config = local.hcp_config
}