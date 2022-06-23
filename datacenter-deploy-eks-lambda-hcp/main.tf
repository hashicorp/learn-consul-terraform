module "tutorial_infrastructure" {
  source               = "./modules/deploy-tutorial"
  tutorial_config      = local.tutorial_config
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --alias lambdaTutorial --name ${local.unique_kube_cluster_name}"
  }
  depends_on = [module.tutorial_infrastructure]
}
