locals {
  shared_annotations_with_prometheus = merge(var.shared_annnotations, var.shared_annotations_prometheus)
  consul_secrets = {
    consul-bootstrap_token = {
      "token" = var.consul_http_token
    }
    consul-ca_cert = {
      "tls.crt" = var.consul_ca
    }
    consul-gossip_key = {
      "key" = var.consul_gossip_key
    }
  }
  working_pod_env_vars = [
    {
      name  = "CONSUL_CA"
      value = var.consul_ca
    },
    {
      name  = "CONSUL_HTTP_TOKEN"
      value = var.consul_http_token
    },
    {
      name  = "CONSUL_CONFIG"
      value = var.consul_config
    },
    {
      name = "CONSUL_HTTP_ADDR"
      value = var.consul_http_addr
    },
    {
      name = "KUBE_CLUSTER_ENDPOINT"
      value = var.kube_cluster_endpoint
    },
    {
      name = "CONSUL_ACCESSOR_ID"
      value = var.consul_accessor_id
    },
    {
      name = "CONSUL_SECRET_ID"
      value = var.consul_secret_id
    },
    {
      name = "AWS_PROFILE"
      value = var.profile_name
    }
  ]
}

module "iam_role_for_service_accounts" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
}

resource "kubernetes_secret" "consul_secrets" {
  for_each = var.kube_secrets
  metadata {
    name = each.key
  }
  type = each.value.secret_type
  data = merge(each, local.consul_secrets[each.key])
}

# Create a service account for this pod
resource "kubernetes_service_account" "working-environment" {
  metadata {
    name = var.cluster_service_account_name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.role_arn
    }
  }
}
resource "kubernetes_service_account" "hashicups_service_accounts" {
  for_each = var.service_variables
  metadata {
    name = each.value.ServiceAccount.sa_name
  }
  automount_service_account_token = each.value.ServiceAccount.automount_service_account_token
}

# ConfigMap for the Pod's startup script
# AWS Credentials file that uses IAM Role and references the profile created below.
resource "kubernetes_config_map" "hashicups_config_maps" {
  for_each = { for k, v in var.service_variables : k => v if v.has_cm == true }
  metadata {
    name = each.value.ConfigMap.cm_name
  }
  data = {
    config = each.value.ConfigMap.cm_data.config
  }
  depends_on = [kubernetes_service_account.hashicups_service_accounts]
}
resource "kubernetes_config_map" "startup_script" {
  metadata {
    name = var.startup_script_config_map_options.config_map_name
  }
  data = {
    (var.startup_script_config_map_options.config_map_file_name) = templatefile("${path.module}/${var.startup_script_config_map_options.template_file_name}", {

      kubectl_version    = var.versions.kubectl_version
      helm_version       = var.versions.helm_version
      consul_version     = var.versions.consul_version
      consul_k8s_version = var.versions.consul_k8s_version
      yq_version         = var.versions.yq_version
      aws_region         = var.cluster_region
      cluster_name       = var.cluster_name
    })
  }
}
resource "kubernetes_config_map" "aws_cred_profile" {
  metadata {
    name = var.aws_creds_config_map_options.config_map_name
  }
  data = {
    (var.aws_creds_config_map_options.config_map_filename) = templatefile("${path.module}/${var.aws_creds_config_map_options.template_file_name}", {
      profile_name = var.profile_name
      role_arn     = var.role_arn
    })
  }
}
resource "kubernetes_config_map" "aws_profile_config" {
  metadata {
    name = var.aws_profile_config_map_options.config_map_name
  }
  data = {
    (var.aws_profile_config_map_options.config_map_filename) = templatefile("${path.module}/${var.aws_profile_config_map_options.template_file_name}", {
      profile_name = var.profile_name
      region       = var.cluster_region
    })
  }
}

# Create a cluster role binding for the service account
resource "kubernetes_cluster_role_binding" "tutorial" {
  metadata {
    name = var.cluster_service_account_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"

  }
  subject {
    kind      = "ServiceAccount"
    name      = var.cluster_service_account_name
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind = "Group"
    name = "system:authenticated"
  }
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
  depends_on = [kubernetes_service_account.hashicups_service_accounts]
}


resource "kubernetes_deployment" "hashicups_deployments" {
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
          for_each = [for vol in each.value.Deployment.spec_config.template_config.template_spec_config.volumes_config : vol
                      if each.value.has_vol == true && each.value.has_empty_dir == true ]
          content {
            name = volume.value.volume_name
            dynamic "config_map" {
              for_each = [ for vl in volume.value.config_maps_config : vl
                           if each.value.has_cm == true ]
              content {
                name = config_map.value.config_map_name
                items {
                  key  = config_map.value.config_file_key
                  path = config_map.value.config_file
                }
              }
            }
            empty_dir {}
          }
        }

        dynamic "volume" {
          for_each = [for vol in each.value.Deployment.spec_config.template_config.template_spec_config.volumes_config : vol
                      if each.value.has_vol == true && each.value.has_empty_dir == false ]
          content {
            name = volume.value.volume_name
            dynamic "config_map" {
              for_each = [
              for vl in volume.value.config_maps_config : vl
              if each.value.has_cm == true
              ]
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
            image = container.value.container_image
            image_pull_policy = container.value.image_pull_policy
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
  depends_on = [kubernetes_service_account.hashicups_service_accounts]
}
resource "kubernetes_deployment" "workingEnvironment" {
  metadata {
    name = var.working-pod-name
    labels = {
      app = var.working-pod-name
    }
  }
  spec {
    replicas = var.pod_replicas
    selector {
      match_labels = {
        app = var.working-pod-name
      }
    }
    template {
      metadata {
        name = var.working-pod-name
        labels = {
          app = var.working-pod-name
        }
        annotations = {
          "consul.hashicorp.com/connect-inject"  = true
          "consul.hashicorp.com/connect-service" = var.working-pod-name
          "eks.amazonaws.com/role-arn"           = var.role_arn
        }
      }

      spec {
        service_account_name            = var.cluster_service_account_name
        automount_service_account_token = true
        volume {
          name = var.startup_script_config_map_options.volume_name
          config_map {
            name         = var.startup_script_config_map_options.config_map_name
            default_mode = var.startup_script_config_map_options.file_permissions
          }
        }
        volume {
          name = var.aws_creds_config_map_options.volume_name
          config_map {
            name         = var.aws_creds_config_map_options.config_map_name
            default_mode = var.aws_creds_config_map_options.file_permissions
          }
        }
        volume {
          name = var.aws_profile_config_map_options.volume_name
          config_map {
            name         = var.aws_profile_config_map_options.config_map_name
            default_mode = var.aws_profile_config_map_options.file_permissions
          }
        }
        container {
          port {
            container_port = 8080
          }
          dynamic "env" {
            for_each = local.working_pod_env_vars
            content {
              name = env.value.name
              value = env.value.value
            }
          }
          name  = var.working-pod-name
          image = var.versions.amazonlinux
          volume_mount {
            mount_path = var.startup_script_config_map_options.mount_path
            name       = var.startup_script_config_map_options.volume_name
          }
          volume_mount {
            mount_path = var.aws_creds_config_map_options.mount_path
            name       = var.aws_creds_config_map_options.volume_name
            sub_path   = var.aws_creds_config_map_options.config_map_filename
            read_only  = true
          }
          volume_mount {
            mount_path = var.aws_profile_config_map_options.mount_path
            name       = var.aws_profile_config_map_options.volume_name
            sub_path   = var.aws_profile_config_map_options.config_map_filename
            read_only  = true
          }
          command = [var.startup_script_config_map_options.startup_command]
        }
      }
    }
  }
  depends_on = [kubernetes_config_map.startup_script, kubernetes_config_map.aws_cred_profile, kubernetes_config_map.aws_profile_config]
}

resource "time_sleep" "waiting_for_pod" {
  create_duration = "30s"
  depends_on = [
    kubernetes_deployment.workingEnvironment
  ]
}

# Render the IAM role file partial to add to the aws-auth configmap
resource "local_file" "add_iam_role" {
  content = templatefile("${path.module}/template_scripts/aws-auth.yaml.tftpl", {
    role_arn                = var.role_arn
    cluster_service_account = var.cluster_service_account_name
  })
  filename = "./aws_auth.yaml"
}


# Add the IAM role to the aws-auth configmap
resource "null_resource" "add_iam_role" {

  provisioner "local-exec" {
    command = "bash ${path.module}/template_scripts/add_iam_role.sh"
  }
  depends_on = [local_file.add_iam_role]

}
resource "null_resource" "exec_inside_container" {
  environment = {
    POD_NAME = var.working-pod-name
  }
  interpreter = var.container_interpreter

  provisioner "local-exec" {
    command = var.container_cluster_bootstrap_script
  }
}


# Upload the hashicups planfiles to a configmap, so the reader doesn't have to do this step.
#resource "null_resource" "hashicups_to_cm" {
#  provisioner "local-exec" {
#    command = "kubectl create configmap hashicups --from-file=${path.module}/../../hashicups -o yaml"
#  }
#}

#resource "kubernetes_secret" "bootstrap_token" {
#  metadata {
#    name = "consul-bootstrap-token"
#  }
#  type = "Opaque"
#  data = {
#    "token" = var.aws_config.consul_bootstrap_token
#  }
#}
#
#resource "kubernetes_secret" "consul_ca_cert" {
#  metadata {
#    name = "consul-ca-cert"
#  }
#  type = "Opaque"
#  data = {
#    "tls.crt" = var.aws_config.consul_ca_certificate
#  }
#}
#
#resource "kubernetes_secret" "consul_gossip_key" {
#  metadata {
#    name = "consul-gossip-key"
#  }
#  type = "Opaque"
#  data = {
#    "key" = var.aws_config.consul_gossip_key
#  }
#  depends_on = [kubernetes_secret.bootstrap_token, kubernetes_secret.consul_ca_cert]
#}


