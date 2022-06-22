locals {
  kube_secrets = {
    consul-bootstrap_token = {

      metadata = {
        name = "consul-bootstrap-token"
      }
      secret_type = "Opaque"
      data        = {
        key_name = "token"
        value = var.consul_http_token
      }
    }
    consul-ca_cert = {
      metadata = {
        name = "consul-ca-cert"
      }
      secret_type = "Opaque"
      data        = {
        key_name = "tls.crt"
        value = base64decode(var.consul_ca)
      }
    }
    consul-gossip_key = {
      metadata = {
        name = "consul-gossip-key"
      }
      secret_type = "Opaque"
      data        = {
        key_name = "key"
        value = var.consul_gossip_key
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
    sipm = "serviceintentions-payments.yaml"
    sipg = "serviceintentions-postgres.yaml"
    sipa = "serviceintentions-product-api.yaml"
    siba = "serviceintentions-public-api.yaml"
    srpm = "serviceresolver-payments-lambda.yaml"
    sspm = "servicesplitter-payments-lambda.yaml"
    tgpm = "terminatinggateway-payments-lambda.yaml"
  }
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

## AWS Credentials file that uses IAM Role and references the profile created below.
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

      kubectl_version    = var.startup_options.kubectl_version
      helm_version       = var.startup_options.helm_version
      consul_version     = var.startup_options.consul_version
      consul_k8s_version = var.startup_options.consul_k8s_version
      yq_version         = var.startup_options.yq_version
      aws_region         = var.cluster_region
      cluster_name       = var.cluster_name
      hashi_repo        = var.startup_options.hashi_repo
      hashi_yum_url     = var.startup_options.hashi_yum_url
      github_content_url = var.startup_options.github_content_url
      github_url        = var.startup_options.github_url
      kube_url          = var.startup_options.kube_url
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
resource "kubernetes_config_map" "hashicups_yaml_files" {
  for_each = fileset(path.module, "hashicups/app/*")
  metadata {
    name = split("/", "${path.module}/${each.value}")[5]
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "calculated_consul_values" {
  metadata {
    name = "values.yaml"

  }
  data = {
      # This is picking up from the working-environment dir.
      # I don't like hardcoding this path, but can fix this later.
      config = file("./rendered/values.yaml")
    }
}
resource "kubernetes_config_map" "crd_proxydefault" {
  metadata {
    name = "proxydefault"
  }
  data = {
    config = file("${path.module}/hashicups/crds/proxy-defaults/proxy-global.yaml")
  }
}
resource "kubernetes_config_map" "crd_servicedefaults" {
  for_each = fileset(path.module, "hashicups/crds/service-defaults/*")
  metadata {
    name = "servicedefaults-${split("/", "${path.module}/${each.value}")[6]}"
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "crd_serviceintentions" {
  for_each = fileset(path.module, "hashicups/crds/service-intentions/*")
  metadata {
    name = "serviceintentions-${split("/", "${path.module}/${each.value}")[6]}"
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "crd_terminatinggateway" {
  metadata {
    name = "terminatinggateway-payments-lambda.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/crds/terminating-gateway/payments-lambda.yaml")
  }
}
resource "kubernetes_config_map" "crd_servicesplitter" {
  metadata {
    name = "servicesplitter-payments-lambda.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/crds/service-splitter/payments-lambda.yaml")
  }
}
resource "kubernetes_config_map" "crd_serviceresolver" {
  metadata {
    name = "serviceresolver-payments-lambda.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/crds/service-resolver/payments-lambda.yaml")
  }
}
resource "kubernetes_config_map" "cleanupcrds" {

  metadata {
    name = var.cleanup_crd_options.config_map_name
  }
  data = {
    config = file("${path.module}/scripts/cleanup_crds.sh")
  }
}


resource "kubernetes_config_map" "consul-api-gateway" {
  metadata {
    name = "consul-api-gateway.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/api-gateway/consul.yaml")
  }
}
resource "kubernetes_config_map" "consul-api-gateway-routes" {

  metadata {
    name = "consul-api-gateway-routes.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/api-gateway/routes.yaml")
  }
}

data "kustomization" "gateway_crds" {
  path = "github.com/hashicorp/consul-api-gateway/config/crd?ref=v${var.api_gateway_version}"
}
resource "kustomization_resource" "gateway_crds" {
  for_each = data.kustomization.gateway_crds.ids
  manifest = data.kustomization.gateway_crds.manifests[each.value]
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
          name = var.cleanup_crd_options.volume_name
          config_map {
            name         = var.cleanup_crd_options.config_map_name
            default_mode = var.cleanup_crd_options.file_permissions
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
                    key = "config"
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
                    key = "config"
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
              name = env.value.name
              value = env.value.value
            }
          }
          name  = var.working-pod-name
          image = var.startup_options.amazonlinux
          volume_mount {
            mount_path = var.consul_values_config_map_options.mount_path
            name       = var.consul_values_config_map_options.volume_name
          }
          volume_mount {
            mount_path = "/hashicups/app"
            name       = "hashicups"
          }
          volume_mount {
            mount_path = "/kube-crds"
            name       = "consulcrds"
          }
          volume_mount {
            mount_path = var.cleanup_crd_options.mount_path
            name       = var.cleanup_crd_options.volume_name
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
      }
    }

  }

  # The cleanup script on destroy event should finish before the tutorial pod is removed.
  depends_on = [null_resource.cleanup, kubernetes_config_map.startup_script, kubernetes_config_map.aws_cred_profile, kubernetes_config_map.aws_profile_config]
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
    command = "bash ${path.module}/scripts/add_iam_role.sh"
  }
  depends_on = [local_file.add_iam_role]

}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when = destroy
    command = "bash ${path.module}/scripts/cleanup_crds.sh"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl get deployments | awk {'print $1'} | grep -v NAME | grep -v tutorial | xargs kubectl delete deployments"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl get pods -l app=tutorial | awk {'print $1'} | grep -v NAME | xargs -I {} kubectl exec {} -- consul-k8s uninstall -auto-approve"
  }
}