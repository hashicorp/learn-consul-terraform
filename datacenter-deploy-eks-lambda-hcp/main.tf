module "tutorial_infrastructure" {
  source               = "./modules/deploy-tutorial"
  tutorial_config      = local.tutorial_config
}

resource "null_resource" "update_kubeconfig" {
  triggers = {
    # Destroy-time provisioners can't reference variables outside of the resource scope. Adding the kubeconfig
    # to the triggers map in null_resource to access via `self.triggers.kubeconfig_file`.
    kubeconfig_file = local.kubeconfig_file
  }
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region}  update-kubeconfig --kubeconfig ${local.kubeconfig_file} --alias ${var.kube_ctx_alias} --name ${local.unique_kube_cluster_name}"
  }
  depends_on = [module.tutorial_infrastructure]

  provisioner "local-exec" {
    when = destroy
    # Removing the tutorial's kubeconfig. Unless the reader changes this explicitly, the tutorial kubeconfig is not the default kubeconfig.
    command = "rm ${self.triggers.kubeconfig_file}" #$HOME/.kube/${self.triggers.kubeconfig_file}"
  }
}