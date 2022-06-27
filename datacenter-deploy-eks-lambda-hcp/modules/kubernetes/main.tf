locals {
  kube_secrets = {
    consul-bootstrap_token = {

      metadata = {
        name = "consul-bootstrap-token"
      }
      secret_type = "Opaque"
      data = {
        key_name = "token"
        value    = var.consul_http_token
      }
    }
    consul-ca_cert = {
      metadata = {
        name = "consul-ca-cert"
      }
      secret_type = "Opaque"
      data = {
        key_name = "tls.crt"
        value    = base64decode(var.consul_ca)
      }
    }
    consul-gossip_key = {
      metadata = {
        name = "consul-gossip-key"
      }
      secret_type = "Opaque"
      data = {
        key_name = "key"
        value    = var.consul_gossip_key
      }
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
      name  = "CONSUL_HTTP_ADDR"
      value = var.consul_http_addr
    },
    {
      name  = "KUBE_CLUSTER_ENDPOINT"
      value = var.kube_cluster_endpoint
    },
    {
      name  = "CONSUL_ACCESSOR_ID"
      value = var.consul_accessor_id
    },
    {
      name  = "CONSUL_SECRET_ID"
      value = var.consul_secret_id
    },
    {
      name  = "AWS_PROFILE"
      value = var.profile_name
    }
  ]
  cm_crd_names = {
    sdfe = "servicedefaults-frontend.yaml"
    sdng = "servicedefaults-nginx.yaml"
    sdpm = "servicedefaults-payments.yaml"
    sdpg = "servicedefaults-postgres.yaml"
    sdpa = "servicedefaults-product-api.yaml"
    sife = "serviceintentions-frontend.yaml"
    sipm = "serviceintentions-payments.yaml"
    sipg = "serviceintentions-postgres.yaml"
    sipa = "serviceintentions-product-api.yaml"
    siba = "serviceintentions-public-api.yaml"
    srpm = "serviceresolver-payments-lambda.yaml"
    sspm = "servicesplitter-payments-lambda.yaml"
    tgpm = "terminatinggateway-payments-lambda.yaml"
    gbpd = "proxy-defaults.yaml"
  }
  api_gw_cmaps = {
    gw     = "consul-api-gateway.yaml"
    routes = "consul-api-gateway-routes.yaml"
  }
}

data "kustomization_build" "gateway_crds" {
  path = "github.com/hashicorp/consul-api-gateway/config/crd?ref=v${var.api_gateway_version}"
}
resource "kustomization_resource" "gateway_crds" {
  for_each = data.kustomization_build.gateway_crds.ids
  manifest = data.kustomization_build.gateway_crds.manifests[each.value]
}

resource "kubernetes_secret" "consul_secrets" {
  for_each = local.kube_secrets
  metadata {
    name = each.value.metadata.name
  }
  type = each.value.secret_type
  data = {
    "${each.value.data.key_name}" = each.value.data.value
  }
}

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
          name = var.shutdown_script_config_map_options.volume_name
          config_map {
            name         = var.shutdown_script_config_map_options.config_map_name
            default_mode = var.shutdown_script_config_map_options.file_permissions
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
        volume {
          name = var.consul_values_config_map_options.volume_name
          config_map {
            name         = var.consul_values_config_map_options.config_map_name
            default_mode = var.consul_values_config_map_options.file_permissions
          }
        }
        volume {
          name = var.startup_init_script_config_map_options.volume_name
          config_map {
            name         = var.startup_init_script_config_map_options.config_map_name
            default_mode = var.startup_init_script_config_map_options.file_permissions
          }
        }
        # Hashicups Volumes
        volume {
          name = "hashicups"
          projected {
            dynamic "sources" {
              for_each = var.hashicups_volume_and_mount_config
              content {
                config_map {
                  name = sources.value.config_map_filename
                  items {
                    key  = sources.value.config_map_key
                    path = sources.value.config_map_filename
                  }
                }
              }
            }
          }
        }
        volume {
          name = "consulcrds"
          projected {
            default_mode = "0755"
            dynamic "sources" {

              for_each = local.cm_crd_names
              content {
                config_map {
                  name = sources.value
                  items {
                    key  = "config"
                    path = sources.value
                  }
                }
              }
            }
          }
        }
        volume {
          name = "consulapigateway"
          projected {
            default_mode = "0755"
            dynamic "sources" {

              for_each = local.api_gw_cmaps
              content {
                config_map {
                  name = sources.value
                  items {
                    key  = "config"
                    path = sources.value
                  }
                }
              }
            }
          }
        }
        container {
          port {
            container_port = 8080
          }
          dynamic "env" {
            for_each = local.working_pod_env_vars
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
          name  = var.working-pod-name
          image = var.startup_options.amazonlinux
          lifecycle {
            pre_stop {
              exec {
                command = [var.shutdown_script_config_map_options.shutdown_command]
              }
            }
          }
          volume_mount {
            mount_path = var.consul_values_config_map_options.mount_path
            name       = var.consul_values_config_map_options.volume_name
          }
          volume_mount {
            mount_path = "/hashicups/app"
            name       = "hashicups"
          }
          volume_mount {
            mount_path = "/api-gateway"
            name       = "consulapigateway"
            read_only  = true
          }
          volume_mount {
            mount_path = "/kube-crds"
            name       = "consulcrds"
          }
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
        init_container {
          name  = "${var.working-pod-name}-init"
          image = var.startup_options.amazonlinux
          dynamic "env" {
            for_each = local.working_pod_env_vars
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
          volume_mount {
            mount_path = "/hashicups/app"
            name       = "hashicups"
          }
          volume_mount {
            mount_path = "/api-gateway"
            name       = "consulapigateway"
            read_only  = true
          }
          volume_mount {
            mount_path = "/kube-crds"
            name       = "consulcrds"
          }
          volume_mount {
            mount_path = var.startup_init_script_config_map_options.mount_path
            name       = var.startup_init_script_config_map_options.volume_name
          }
          volume_mount {
            mount_path = var.consul_values_config_map_options.mount_path
            name       = var.consul_values_config_map_options.volume_name
          }
          volume_mount {
            mount_path = var.aws_profile_config_map_options.mount_path
            name       = var.aws_profile_config_map_options.volume_name
            sub_path   = var.aws_profile_config_map_options.config_map_filename
            read_only  = true
          }
          command = [var.startup_init_script_config_map_options.startup_init_command]
        }
      }

    }

  }

  depends_on = [kubernetes_config_map.calculated_consul_values, kustomization_resource.gateway_crds, kubernetes_config_map.aws_cred_profile, kubernetes_config_map.aws_profile_config]
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
    environment = {
      KUBECONFIG  = var.kubeconfig
      KUBECONTEXT = var.kube_ctx_alias
    }
    command = "bash ${path.module}/scripts/add_iam_role.sh"
  }
  depends_on = [local_file.add_iam_role]

}