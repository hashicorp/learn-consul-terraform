variable "startup_options" {
  type        = any
  description = "Versions of software used in the startup script"
  default = {
    kubectl_version    = "v1.22.4"
    helm_version       = "v3.7.1"
    consul_version     = "1.12.2"
    consul_k8s_version = "0.44.0"
    amazonlinux        = "amazonlinux:2"
    yq_version         = "v4.20.2"
    hashi_repo         = "https://releases.hashicorp.com"
    hashi_yum_url      = "https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo"
    github_content_url = "https://raw.githubusercontent.com"
    kube_url           = "https://dl.k8s.io/release"
    github_url         = "https://github.com"
  }
}

variable "api_gateway_version" {
  type    = string
  default = "0.2.1"
}

variable "consul_ca" {
  type        = string
  description = "Consul CA File"
}

variable "consul_http_token" {
  description = "Consul HTTP Token for CLI/API access"
  type        = string
}

variable "consul_config" {
  type        = string
  description = "Consul Config file, base64 encoded"
}

variable "consul_http_addr" {
  description = "HCP Consul Cluster endpoint"
  type        = string
}

variable "kube_cluster_endpoint" {
  description = "Kubernetes cluster endpoint URL"
  type        = string
}

variable "consul_accessor_id" {
  description = "Accessor ID for token"
  type        = string
}

variable "consul_secret_id" {
  description = "Secret ID for token"
  type        = string
}

variable "pod_replicas" {
  description = "Number of pod replicas for the working environment"
  default     = "1"
}

variable "pod_name" {
  description = "Name of tutorial working environment"
  default     = "tutorial"
}

variable "kube_context" {
  type        = string
  description = "The name of the kube context to set in the config file for kubectl"
}

variable "profile_name" {
  type        = string
  description = "Name of the AWS Profile"
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM Role that is mapped to a Kubernetes service account"
}

variable "cluster_name" {
  type        = string
  description = "Name for the EKS cluster."
}

variable "cluster_region" {
  type        = string
  description = "Region of EKS cluster."
}

variable "cluster_service_account_name" {
  type        = string
  description = "Name of the Kubernetes service account mapped to the IAM Role."
}

variable "startup_script_config_map_options" {
  type        = any
  description = "Configuration settings for the kube configmap for the startup script"
  default = {
    file_permissions     = "0744"
    config_map_name      = "tutorial-startup-scripts"
    config_map_file_name = "startup.sh"
    mount_path           = "/startup"
    startup_command      = "/startup/startup.sh"
    volume_name          = "startup"
    template_file_name   = "template_scripts/startup-script.tftpl"
  }
}

variable "shutdown_script_config_map_options" {
  type        = any
  description = "Configuration settings for the kube configmap for the startup script"
  default = {
    file_permissions     = "0744"
    config_map_name      = "tutorial-shutdown-scripts"
    config_map_file_name = "shutdown.sh"
    mount_path           = "/shutdown"
    shutdown_command     = "/shutdown/shutdown.sh"
    volume_name          = "shutdown"
    template_file_name   = "template_scripts/shutdown-script.tftpl"
  }
}

variable "startup_init_script_config_map_options" {
  type        = any
  description = "Configuration settings for the kube configmap for the startup script"
  default = {
    file_permissions     = "0744"
    config_map_name      = "tutorial-startup-init"
    config_map_file_name = "startup-init.sh"
    mount_path           = "/startup-init"
    startup_init_command = "/startup-init/startup-init.sh"
    volume_name          = "startup-init"
    template_file_name   = "template_scripts/startup-init.tftpl"
  }
}

variable "consul_datacenter" {}

variable "consul_image" {
  default = "hashicorp/consul:1.12.2"
}

variable "aws_creds_config_map_options" {
  type        = any
  description = "Creates the AWS credentials file which is directed towards the IAM Role associated with the Pod. Does not use password or token based authentication"
  default = {
    config_map_name     = "aws-credentials"
    config_map_filename = "credentials"
    mount_path          = "/root/.aws/credentials"
    volume_name         = "aws-credentials"
    template_file_name  = "template_scripts/aws-credentials.tftpl"
    file_permissions    = "0755"
  }
}

variable "consul_values_config_map_options" {
  type        = any
  description = "Consul Values file for Helm."
  default = {
    config_map_name     = "values.yaml"
    config_map_filename = "consul-values.yaml"
    mount_path          = "/helm"
    volume_name         = "consul-values"
    file_permissions    = "0755"
  }
}

variable "shell_get_tutorial_pod" {
  default = "kubectl get pods -l app=tutorial -o json | jq -r '.items[0].metadata.name'"
}

variable "cleanup_crd_options" {
  type        = any
  description = "Clean up trailing CRDs on deletion"
  default = {
    config_map_name     = "cleanupcrds"
    config_map_filename = "cleanup.sh"
    mount_path          = "/cleanup.sh"
    volume_name         = "cleanupcrds"
    template_file_name  = "template_scripts/aws-credentials.tftpl"
    file_permissions    = "0755"
  }
}

variable "hashicups_volume_and_mount_config" {
  default = {
    postgres = {
      config_map_name     = "postgres.yaml"
      config_map_key      = "config"
      config_map_filename = "postgres.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "postgres"
      file_permissions    = "0755"
    }
    payments = {
      config_map_name     = "payments.yaml"
      config_map_key      = "config"
      config_map_filename = "payments.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "payments"
      file_permissions    = "0755"
    }
    product-api = {
      config_map_name     = "product-api.yaml"
      config_map_key      = "config"
      config_map_filename = "product-api.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "product-api"
      file_permissions    = "0755"
    }
    public-api = {
      config_map_name     = "public-api.yaml"
      config_map_key      = "config"
      config_map_filename = "public-api.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "public-api"
      file_permissions    = "0755"
    }
    frontend = {
      config_map_name     = "frontend.yaml"
      config_map_key      = "config"
      config_map_filename = "frontend.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "frontend"
      file_permissions    = "0755"
    }
    nginx = {
      config_map_name     = "nginx.yaml"
      config_map_key      = "config"
      config_map_filename = "nginx.yaml"
      mount_path          = "/hashicups/app"
      volume_name         = "nginx"
      file_permission     = "0755"

    }
  }
}
variable "consul_gossip_key" {}

variable "aws_profile_config_map_options" {
  type        = any
  description = "Settings for the AWS profile configmap"
  default = {
    config_map_name     = "aws-profile"
    config_map_filename = "config"
    mount_path          = "/root/.aws/config"
    volume_name         = "aws-profile"
    template_file_name  = "template_scripts/aws-profile-config.tftpl"
    file_permissions    = "0755"
  }
}

variable "service_variables" {
  type = any
  default = {
    payments = {
      has_empty_dir = false
      has_vol       = false
      has_cm        = false
      ServiceAccount = {
        sa_name                         = "payments"
        automount_service_account_token = true
      }
      Service = {
        spec_type = ""
        ports = [
          {
            pname     = "http"
            pprotocol = "TCP"
            ptarget   = 8080
            pport     = 1800
          }
        ]
      }
      ConfigMap = {
        cm_name = null
        cm_data = {
          config = null
        }
      }
    }
    public-api = {
      has_empty_dir = false
      has_cm        = false
      has_vol       = false
      ServiceAccount = {
        sa_name                         = "public-api"
        automount_service_account_token = true
      }
      Service = {
        spec_type = "ClusterIP"
        ports = [
          {
            #pname     = null
            #pprotocol = null
            ptarget = 8080
            pport   = 8080
          }
        ]
      }
      ConfigMap = {
        cm_name = null
        cm_data = {
          config = null
        }
      }
    }
    product-api = {
      has_empty_dir = false
      has_cm        = true
      has_vol       = true
      ServiceAccount = {
        sa_name                         = "product-api"
        automount_service_account_token = true
      }
      Service = {
        spec_type = ""
        ports = [
          {
            pname     = "http"
            pprotocol = "TCP"
            ptarget   = 9090
            pport     = 9090
          }
        ]
      }
      ConfigMap = {
        cm_name = "db-configmap"
        cm_data = {
          config = <<EOF
          {
            "db_connection": "host=localhost port=5432 user=postgres password=password dbname=products sslmode=disable",
            "bind_address": ":9090",
            "metrics_address": ":9103"
          }
          EOF
        }
      }
    }
    postgres = {
      has_cm        = false
      has_vol       = true
      has_empty_dir = true
      ServiceAccount = {
        sa_name                         = "postgres"
        automount_service_account_token = true
      }
      Service = {
        spec_type = "ClusterIP"
        ports = [
          {
            ptarget = 5432
            pport   = 5432
          }
        ]
      }
      ConfigMap = {
        cm_name = null
        cm_data = {
          config = null
        }
      }

    }
    frontend = {
      has_cm        = false
      has_vol       = false
      has_empty_dir = false
      ServiceAccount = {
        sa_name                         = "frontend"
        automount_service_account_token = true
      }
      Service = {
        spec_type = "ClusterIP"
        ports = [
          {
            ptarget = 3000
            pport   = 3000
          }
        ]
      }
      ConfigMap = {
        cm_name = null
        cm_data = {
          config = null
        }
      }
    }
    nginx = {
      has_cm        = true
      has_vol       = true
      has_empty_dir = false
      ServiceAccount = {
        sa_name                         = "nginx"
        automount_service_account_token = true
      }
      Service = {
        spec_type = "ClusterIP"
        ports = [
          {
            ptarget = 80
            pport   = 80
          }
        ]
      }
      ConfigMap = {
        cm_name = "nginx-config"
        cm_data = {
          config = <<EOF
          events {}
              http {
                include /etc/nginx/conf.d/*.conf;
                 server {
                    server_name localhost;
                    listen 80 default_server;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection 'upgrade';
                    proxy_set_header Host $host;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_temp_file_write_size 64k;
                    proxy_connect_timeout 10080s;
                    proxy_send_timeout 10080;
                    proxy_read_timeout 10080;
                    proxy_buffer_size 64k;
                    proxy_buffers 16 32k;
                    proxy_busy_buffers_size 64k;
                    proxy_redirect off;
                    proxy_request_buffering off;
                    proxy_buffering off;
                    location / {
                      proxy_pass http://127.0.0.1:3000;
                    }
                    location ^~ /hashicups {
                      rewrite ^/hashicups(.*)$ /$1 last;
                    }
                    location /static {
                      proxy_cache_valid 60m;
                      proxy_pass http://127.0.0.1:3000;
                    }
                    location /api {
                      proxy_pass http://127.0.0.1:8080;
                    }
                    error_page   500 502 503 504  /50x.html;
                    location = /50x.html {
                      root   /usr/share/nginx/html;
                    }
                  }
                }
          EOF
        }
      }
    }
  }
}

variable "global_kube_resources" {
  default = {
    payments = {
      has_volumes       = false
      has_volume_mounts = false
    }
    public-api = {
      has_volumes       = false
      has_volume_mounts = false
    }
    product-api = {
      has_volumes       = true
      has_configmap     = true
      has_volume_mounts = true
    }
    postgres = {
      has_volumes       = true
      has_configmap     = false
      has_volume_mounts = true
    }
    frontend = {
      has_volumes       = false
      has_volume_mounts = false
    }
  }
}

variable "container_interpreter" {
  default = ["/bin/bash", "-c"]
}

variable "working-pod-service_account" {}

variable "working-pod-name" {}

variable "working-pod-container_port" {
  default = 8080
}

variable "kube_cluster_ca" {}

variable "kubeconfig" {}

variable "kube_ctx_alias" {}