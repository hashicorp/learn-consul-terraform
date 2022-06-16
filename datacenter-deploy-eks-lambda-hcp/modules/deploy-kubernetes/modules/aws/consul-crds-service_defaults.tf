resource "kubectl_manifest" "hashicups_service_defaults" {
  for_each  = var.custom_resource_definitions_config.ServiceDefaults
  yaml_body = <<YAML
apiVersion: ${var.consul_kube_api_creds.ServiceDefaults.apiVersion}
kind: ServiceDefaults
metadata:
  name: ${each.value.metadata.name}
spec:
  protocol: ${each.value.spec.protocol}

YAML

  provisioner "local-exec" {
<<<<<<< HEAD:datacenter-deploy-eks-lambda-hcp/modules/deploy-kubernetes/modules/eks/consul-crds-service_defaults.tf
    when = destroy
    command =  "bash ${path.module}/cleanup.sh"
    #command =  "kubectl patch servicedefaults ${each.key} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge && kubectl delete servicedefaults ${each.key} --ignore-not-found=true"
    environment = {
      SERVICETYPE="servicedefaults"
      SERVICENAME=each.key
=======
    when    = destroy
    command = "bash ${path.module}/cleanup.sh"
    #command =  "kubectl patch servicedefaults ${each.key} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge && kubectl delete servicedefaults ${each.key} --ignore-not-found=true"
    environment = {
      SERVICETYPE = "servicedefaults"
      SERVICENAME = each.key
>>>>>>> origin/im2nguyen/serverless-consul-lambda-function:datacenter-deploy-eks-lambda-hcp/modules/deploy-kubernetes/modules/aws/consul-crds-service_defaults.tf
    }
  }
  depends_on = [helm_release.consul_enterprise]
}
