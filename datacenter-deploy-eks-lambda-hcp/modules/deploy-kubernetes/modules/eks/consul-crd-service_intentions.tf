resource "kubectl_manifest" "hashicups_service_intentions" {
  for_each = var.custom_resource_definitions_config.ServiceIntentions

  yaml_body = <<YAML
apiVersion: ${var.consul_kube_api_creds.ServiceIntentions.apiVersion}
kind: ServiceIntentions
metadata:
  name: ${each.value.metadata.name}
  namespace: ${each.value.metadata.namespace}
spec:
  sources:
    - name: ${each.value.sources[0].name}
      action: ${each.value.sources[0].action}
      namespace: ${each.value.sources[0].namespace}
  destination:
    name: ${each.value.destination.name}
    namespace: ${each.value.destination.namespace}

  YAML

  triggers = {

  }
  provisioner "local-exec" {
    # Part of the pre-reqs involve using kubectl, so this is not optimal, but okay given the environment
    when    = destroy
    command = "bash ${path.module}/cleanup.sh"
    environment = {
      SERVICETYPE="serviceintentions"
      SERVICENAME=each.key
    }
  }
  depends_on = [helm_release.consul_enterprise]
}
