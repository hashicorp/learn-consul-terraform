
resource "kubectl_manifest" "hashicups_service_defaults" {
  for_each = var.custom_resource_definitions_config.ServiceDefaults
  yaml_body = <<YAML
apiVersion: ${var.consul_kube_api_creds.ServiceDefaults.apiVersion}
kind: ServiceDefaults
metadata:
  name: ${each.value.metadata.name}
spec:
  protocol: ${each.value.spec.protocol}

YAML

  provisioner "local-exec" {
    when = destroy
    command =  "kubectl patch servicedefaults ${each.key} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge && kubectl delete servicedefaults ${each.key} --ignore-not-found=true"

  }
}