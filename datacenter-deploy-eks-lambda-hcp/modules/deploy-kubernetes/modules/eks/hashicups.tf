locals {
  shared_annotations_with_prometheus = merge(var.shared_annnotations, var.shared_annotations_prometheus)
}

resource "kubernetes_service_account" "hashicups_service_accounts" {
  for_each = var.service_variables
  metadata {
    name = each.value.ServiceAccount.sa_name
  }
  automount_service_account_token = each.value.ServiceAccount.automount_service_account_token
}

resource "kubernetes_service" "hashicups_services" {
  for_each = var.service_variables
  metadata {
    name = each.key
    labels = {
      app = each.key
    }
  }
  spec {
    type = each.value.Service.spec_type == "" ? null : each.value.Service.spec_type
    dynamic "port" {
      for_each = each.value.Service.ports
      content {
        name        = contains(keys(port), "pname") ? port.value.pname : null
        protocol    = contains(keys(port), "pprotocol") ? port.value.pprotocol : null
        target_port = port.value.ptarget
        port        = port.value.pport
      }
    }
    selector = {
      app = each.key
    }
  }
}

resource "kubernetes_config_map" "hashicups_config_maps" {
  for_each = var.service_variables
  metadata {
    name = each.value.ConfigMap.cm_name
  }
  data = {
    config = each.value.ConfigMap.cm_data.config
  }
}

resource "kubernetes_deployment" "kubernetes_deployments" {
  for_each = var.service_variables
  metadata {
    name = each.key
  }
  spec {
    replicas = each.value.Deployment.spec_config.replica_count
    template {
      metadata {
        labels = each.value.Deployment.spec_config.template_config.metadata_config.labels
        # Add prometheus annotations if the deployment config has a boolean true for `prometheus`, otherwise, just use the common annotations between all pods, and any that may have been passed in the config.
        annotations = each.value.Deployment.spec_config.template_config.metadata_config.prometheus ? merge(each.value.Deployment.spec_config.template_config.metadata_config.annotations, local.shared_annotations_with_prometheus) : merge(var.shared_annnotations, each.value.Deployment.spec_config.template_config.metadata_config.annotations)
      }
      spec {
        service_account_name = each.key
        dynamic "volume" {
          for_each = each.value.Deployment.spec_config.template_config.template_spec_config.volumes_config
          content {
            name = volume.value.volume_name
            dynamic "config_map" {
              for_each = volume.value.config_maps_config
              content {
                name = config_map.value.config_map_name
                items {
                  key  = config_map.value.config_file_key
                  path = config_map.value.config_file
                }
              }
            }
          }
        }

        dynamic "container" {
          for_each = each.value.Deployment.spec_config.template_config.template_spec_config.container_config
          content {
            name = container.value.container_name
            dynamic "volume_mount" {
              for_each = [for vmc in container.value.volume_mounts_config : vmc
                if container.value.vol_mount_conf == true
              ]
              content {
                mount_path = volume_mount.value.mount_path
                name       = volume_mount.value.volume_mount_name
                read_only  = volume_mount.value.read_only ? volume_mount.value.read_only : null
              }
            }
            dynamic "env" {
              for_each = [for e in container.value.environment_variables_config : e
                if container.value.env_config == true
              ]
              content {
                name  = env.value.name
                value = env.value.value
              }
            }
            dynamic "port" {
              for_each = container.value.container_ports_config
              content {
                container_port = port.value.port
                name           = contains(keys(port), "name") ? port.value.name : null
                protocol       = contains(keys(port), "protocol") ? port.value.protocol : null
              }
            }
            dynamic "liveness_probe" {

              for_each = [
                for lv in container.value.liveness_probe_config : lv
                if container.value.liveness == true
              ]
              content {
                http_get {
                  path = liveness_probe.value.path
                  port = liveness_probe.value.port
                }
                initial_delay_seconds = liveness_probe.value.initial_delay_seconds
                timeout_seconds       = liveness_probe.value.timeout_seconds
                period_seconds        = liveness_probe.value.period_seconds
                failure_threshold     = liveness_probe.value.failure_threshold
              }
            }
            args = container.value.container_args_config == null ? [] : container.value.container_args_config
          }
        }
      }
    }
    selector {
      match_labels = each.value.Deployment.spec_config.selector_config.labels
    }
  }
}



