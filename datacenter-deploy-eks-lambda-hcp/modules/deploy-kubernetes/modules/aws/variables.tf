variable "eks_nodes_ami" {
  type        = string
  description = "AMI Type for EKS Nodes"
  default     = "AL2_x86_64"
}

variable "node_disk_size" {
  type        = number
  description = "Disk Size in GB for an EKS Node"
  default     = 50
}

variable "instance_type" {
  type        = string
  description = "Instance type for an EKS node"
  default     = "m5.large"
}

variable "min_instances" {
  type        = number
  description = "Minimum number of EKS Nodes"
  default     = 3
}

variable "max_instances" {
  type        = number
  description = "Maximum Number of EKS Nodes"
  default     = 3
}

variable "desired_instances" {
  type        = number
  description = "Desired number of EKS Nodes"
  default     = 3
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS Cluster. Will be appended with a random string for a unique value"
  default     = "consulLambdaCluster"
}

variable "aws_config" {
  type = object({
    private_subnets    = list(string)
    public_subnets     = list(string)
    security_group_ids = list(string)
    vpc_id             = string
    # consul_ent_license_b64     = string
    consul_bootstrap_token_b64 = string
    consul_ca_certificate_b64  = string
    consul_gossip_key_b64      = string
    hcp_consul_endpoint        = string
    aws_region                 = string
    identifier                 = string
    hcp_datacenter             = string
  })
}

variable "cluster_stage" {
  type        = string
  description = "A tag to define what stage of development an EKS cluster represents"
  default     = "dev"
}

variable "kube_context" {
  type        = string
  description = "Kubeconfig context"
  default     = "default"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "shared_annnotations" {
  type        = map(string)
  description = "Shared annotations by all containers"
  default = {
    "consul.hashicorp.com/connect-inject" = "true"
  }
}

variable "shared_annotations_prometheus" {
  type        = map(string)
  description = "Support for prometheus"
  default = {
    "prometheus.io/scrape" = "true"
    "prometheus.io/port"   = "9102"
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

# HashiCups configuration map, with each service containing the kube config type it requires to operate
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
      Deployment = {
        spec_config = {
          replica_count = 1
          selector_config = {
            labels = {
              app = "payments"
            }
          }
          template_config = {
            metadata_config = {
              labels = {
                app = "payments"
              }
              prometheus  = false
              annotations = {}
            }
            template_spec_config = {
              volumes_config = [{}]
              container_config = [
                {
                  container_name    = "payments"
                  container_image   = "hashicorpdemoapp/payments:v0.0.14"
                  image_pull_policy = "Always"
                  container_ports_config = [
                    {
                      port = 8080
                    }
                  ]
                  vol_mount_conf               = false
                  volume_mounts_config         = [{}]
                  liveness                     = false
                  liveness_probe_config        = [{}]
                  env_config                   = false
                  environment_variables_config = [{}]
                  container_args_config        = []
                }
              ]
            }
          }
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
      Deployment = {
        spec_config = {
          replica_count = 1
          selector_config = {
            labels = {
              app     = "public-api"
              service = "public-api"
            }
          }
          template_config = {
            metadata_config = {
              labels = {
                app     = "public-api"
                service = "public-api"
              }
              prometheus = true
              annotations = {
                "consul.hashicorp.com/connect-service-upstreams" = "product-api:9090, payments:1800"
              }
            }
            template_spec_config = {
              volumes_config = [{}]
              container_config = [
                {
                  container_name       = "public-api"
                  container_image      = "hashicorpdemoapp/public-api:v0.0.6"
                  image_pull_policy    = "Always"
                  vol_mount_conf       = false
                  volume_mounts_config = [{}]
                  env_config           = true
                  environment_variables_config = [
                    {
                      name  = "BIND_ADDRESS"
                      value = ":8080"
                    },
                    {
                      name  = "PRODUCT_API_URI"
                      value = "http://localhost:9090"
                    },
                    {
                      name  = "PAYMENT_API_URI"
                      value = "http://localhost:1800"
                    }
                  ]
                  container_ports_config = [
                    {
                      port = 8080
                    }
                  ]
                  container_args_config = []
                  liveness              = false
                  liveness_probe_config = [{}]
                },
                {
                  container_name               = "jaeger-agent"
                  container_image              = "jaegertracing/jaeger-agent:latest"
                  image_pull_policy            = "IfNotPresent"
                  vol_mount_conf               = false
                  volume_mounts_config         = [{}]
                  env_config                   = false
                  environment_variables_config = [{}]
                  container_ports_config = [
                    {
                      port     = 5775
                      name     = "zk-compact-trft"
                      protocol = "UDP"
                    },
                    {
                      port     = 5778
                      name     = "config-rest"
                      protocol = "TCP"
                    },
                    {
                      port     = 6831
                      name     = "jg-compact-trft"
                      protocol = "UDP"
                    },
                    {
                      port     = 6832
                      name     = "jq-binary-trft"
                      protocol = "UDP"
                    },
                    {
                      port     = 14271
                      name     = "admin-http"
                      protocol = "TCP"
                    }

                  ]
                  container_args_config = [
                    "--reporter.grpc.host-port=dns:///jaeger-collector-headless.default:14250",
                    "--reporter.type=grpc"
                  ]
                  liveness              = false
                  liveness_probe_config = [{}]
                }
              ]
            }
          }
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
      Deployment = {
        spec_config = {
          replica_count = 1
          selector_config = {
            labels = {
              app = "product-api"
            }
          }
          template_config = {
            metadata_config = {
              labels = {
                app = "product-api"
              }
              prometheus = true
              annotations = {
                "consul.hashicorp.com/connect-service-upstreams" = "postgres:5432"
              }
            }
            template_spec_config = {
              volumes_config = [
                {
                  volume_name = "config"
                  config_maps_config = [
                    {
                      config_map_name = "db-configmap"
                      config_file_key = "config"
                      config_file     = "conf.json"
                    }
                  ]
                }
              ]
              container_config = [
                {
                  container_name    = "product-api"
                  container_image   = "hashicorpdemoapp/product-api:v0.0.20"
                  image_pull_policy = "Always"
                  vol_mount_conf    = true
                  volume_mounts_config = [
                    {
                      mount_path        = "/config"
                      volume_mount_name = "config"
                      read_only         = true
                    }
                  ]
                  env_config = true
                  environment_variables_config = [
                    {
                      name  = "CONFIG_FILE"
                      value = "/config/conf.json"
                    }
                  ]
                  container_ports_config = [
                    {
                      port = 9090
                    },
                    {
                      port = 9103
                    }
                  ]
                  container_args_config = []
                  liveness              = true
                  liveness_probe_config = [
                    {
                      method                = "httpGet"
                      path                  = "/health"
                      port                  = 9090
                      initial_delay_seconds = 15
                      timeout_seconds       = 1
                      period_seconds        = 10
                      failure_threshold     = 30
                    }
                  ]
                }
              ]
            }
          }
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
      Deployment = {
        spec_config = {
          replica_count = 1
          selector_config = {
            labels = {
              app     = "postgres"
              service = "postgres"
            }
          }
          template_config = {
            metadata_config = {
              labels = {
                app     = "postgres"
                service = "postgres"
              }
              prometheus  = false
              annotations = {}
            }
            template_spec_config = {
              volumes_config = [
                {
                  volume_name        = "pgdata"
                  config_maps_config = [{}]
                }
              ]
              container_config = [
                {
                  container_name    = "postgres"
                  container_image   = "hashicorpdemoapp/product-api-db:v0.0.20"
                  image_pull_policy = "Always"
                  vol_mount_conf    = true
                  volume_mounts_config = [
                    {
                      mount_path        = "/var/lib/postgresql/data"
                      volume_mount_name = "pgdata"
                      read_only         = false
                    }
                  ]
                  env_config = true
                  environment_variables_config = [
                    {
                      name  = "POSTGRES_DB"
                      value = "products"
                    },
                    {
                      name  = "POSTGRES_USER"
                      value = "postgres"
                    },
                    {
                      name  = "POSTGRES_PASSWORD"
                      value = "password"
                    }
                  ]
                  container_ports_config = [
                    {
                      port = 5432
                    }
                  ]
                  container_args_config = ["-c", "listen_addresses=127.0.0.1"]
                  liveness              = false
                  liveness_probe_config = [{}]
                }
              ]
            }
          }
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
      Deployment = {
        spec_config = {
          replica_count = 1
          selector_config = {
            labels = {
              app     = "frontend"
              service = "frontend"
            }
          }
          template_config = {
            metadata_config = {
              labels = {
                app     = "frontend"
                service = "frontend"
              }
              prometheus  = false
              annotations = {}
            }
            template_spec_config = {
              volumes_config = [{}]
              container_config = [
                {
                  container_name       = "frontend"
                  container_image      = "hashicorpdemoapp/frontend:v1.0.1"
                  image_pull_policy    = "Always"
                  vol_mount_conf       = false
                  volume_mounts_config = [{}]
                  env_config           = true
                  environment_variables_config = [
                    {
                      name  = "NEXT_PUBLIC_PUBLIC_API_URL"
                      value = "http://localhost:8080"
                    }
                  ]
                  container_ports_config = [
                    {
                      port = 3000
                    }
                  ]
                  container_args_config = []
                  liveness              = false
                  liveness_probe_config = [{}]
                }
              ]
            }
          }
        }
      }
    }
    # TODO intentionally commented out, this will allow access to hashicups without a port forward.
    #    nginx = {
    #      has_cm         = false
    #      has_vol        = false
    #      has_empty_dir  = false
    #      ServiceAccount = {
    #        sa_name                         = "nginx"
    #        automount_service_account_token = true
    #      }
    #      Service = {
    #        spec_type = "ClusterIP"
    #        ports     = [
    #          {
    #            ptarget = 80
    #            pport   = 80
    #          }
    #        ]
    #      }
    #      ConfigMap = {
    #        cm_name = "nginx-config"
    #        cm_data = {
    #          "nginx.conf" = <<EOF
    #            events {}
    #            http {
    #              include /etc/nginx/conf.d/*.conf;
    #              server {
    #                server_name localhost;
    #                listen 80 default_server;
    #                proxy_http_version 1.1;
    #                proxy_set_header Upgrade $http_upgrade;
    #                proxy_set_header Connection 'upgrade';
    #                proxy_set_header Host $host;
    #                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #                proxy_temp_file_write_size 64k;
    #                proxy_connect_timeout 10080s;
    #                proxy_send_timeout 10080;
    #                proxy_read_timeout 10080;
    #                proxy_buffer_size 64k;
    #                proxy_buffers 16 32k;
    #                proxy_busy_buffers_size 64k;
    #                proxy_redirect off;
    #                proxy_request_buffering off;
    #                proxy_buffering off;
    #                location / {
    #                  proxy_pass http://127.0.0.1:3000;
    #                }
    #                location /static {
    #                  proxy_cache_valid 60m;
    #                  proxy_pass http://127.0.0.1:3000;
    #                }
    #                location /api {
    #                  proxy_pass http://127.0.0.1:8080;
    #                }
    #                error_page   500 502 503 504  /50x.html;
    #                location = /50x.html {
    #                    root   /usr/share/nginx/html;
    #                    }
    #                  }
    #                }
    #                EOF
    #          Deployment   = {
    #            spec_config = {
    #              replica_count   = 1
    #              selector_config = {
    #                labels = {
    #                  app     = "frontend"
    #                  service = "frontend"
    #                }
    #              }
    #              template_config = {
    #                metadata_config = {
    #                  labels = {
    #                    app     = "frontend"
    #                    service = "frontend"
    #                  }
    #                  prometheus  = false
    #                  annotations = {}
    #                }
    #                template_spec_config = {
    #                  volumes_config   = [{}]
    #                  container_config = [
    #                    {
    #                      container_name               = "frontend"
    #                      container_image              = "hashicorpdemoapp/frontend:v1.0.1"
    #                      image_pull_policy            = "Always"
    #                      vol_mount_conf               = false
    #                      volume_mounts_config         = [{}]
    #                      env_config                   = true
    #                      environment_variables_config = [
    #                        {
    #                          name  = "NEXT_PUBLIC_PUBLIC_API_URL"
    #                          value = "http://localhost:8080"
    #                        }
    #                      ]
    #                      container_ports_config = [
    #                        {
    #                          port = 3000
    #                        }
    #                      ]
    #                      container_args_config = []
    #                      liveness              = false
    #                      liveness_probe_config = [{}]
    #                    }
    #                  ]
    #                }
    #              }
    #            }
    #          }
    #        }
    #      }
    #    }
    #    ingress = {
    #      has_cm         = false
    #      has_vol        = false
    #      has_empty_dir  = false
    #      ServiceAccount = {
    #        sa_name                         = "frontend"
    #        automount_service_account_token = true
    #      }
    #      Service = {
    #        spec_type = "ClusterIP"
    #        ports     = [
    #          {
    #            ptarget = 3000
    #            pport   = 3000
    #          }
    #        ]
    #      }
    #      ConfigMap = {
    #        cm_name = null
    #        cm_data = {
    #          config = null
    #        }
    #      }
    #      Deployment = {
    #        spec_config = {
    #          replica_count   = 1
    #          selector_config = {
    #            labels = {
    #              app     = "frontend"
    #              service = "frontend"
    #            }
    #          }
    #          template_config = {
    #            metadata_config = {
    #              labels = {
    #                app     = "frontend"
    #                service = "frontend"
    #              }
    #              prometheus  = false
    #              annotations = {}
    #            }
    #            template_spec_config = {
    #              volumes_config   = [{}]
    #              container_config = [
    #                {
    #                  container_name               = "frontend"
    #                  container_image              = "hashicorpdemoapp/frontend:v1.0.1"
    #                  image_pull_policy            = "Always"
    #                  vol_mount_conf               = false
    #                  volume_mounts_config         = [{}]
    #                  env_config                   = true
    #                  environment_variables_config = [
    #                    {
    #                      name  = "NEXT_PUBLIC_PUBLIC_API_URL"
    #                      value = "http://localhost:8080"
    #                    }
    #                  ]
    #                  container_ports_config = [
    #                    {
    #                      port = 3000
    #                    }
    #                  ]
    #                  container_args_config = []
    #                  liveness              = false
    #                  liveness_probe_config = [{}]
    #                }
    #              ]
    #            }
    #          }
    #        }
    #      }
    #    }
  }
}

variable "consul_kube_api_creds" {
  default = {
    ServiceIntentions = {
      apiVersion = "consul.hashicorp.com/v1alpha1"
    }
    ServiceDefaults = {
      apiVersion = "consul.hashicorp.com/v1alpha1"
    }
  }
}

variable "custom_resource_definitions_config" {
  default = {
    ServiceIntentions = {
      payments = {
        namespace = "default"
        metadata = {
          "name"      = "payments"
          "namespace" = "default"
        },
        destination = {
          "name"      = "payments"
          "namespace" = "default"
        },
        sources = [{
          "action"    = "allow"
          "name"      = "public-api"
          "namespace" = "default"
        }]
      }
      product-api = {
        namespace = "default"
        metadata = {
          "name"      = "product-api"
          "namespace" = "default"
        },
        destination = {
          "name"      = "product-api"
          "namespace" = "default"
        },
        sources = [{
          "action"    = "allow"
          "name"      = "public-api"
          "namespace" = "default"
        }]
      }
      public-api = {
        namespace = "default"
        metadata = {
          "name"      = "public-api"
          "namespace" = "default"
        },
        destination = {
          "name"      = "public-api"
          "namespace" = "default"
        },
        sources = [
          {
            "action"    = "allow"
            "name"      = "frontend"
            "namespace" = "default"
          }
        ]
      }
      postgres = {
        namespace = "default"
        metadata = {
          "name"      = "postgres"
          "namespace" = "default"
        },
        destination = {
          "name"      = "postgres"
          "namespace" = "default"
        },
        sources = [{
          "action"    = "allow"
          "name"      = "product-api"
          "namespace" = "default"
        }]
      }
    }
    ServiceDefaults = {
      frontend = {
        metadata = {
          "name"      = "frontend"
          "namespace" = "default"
        }
        spec = {
          "protocol" = "http"
        }
      }
      postgres = {
        metadata = {
          "name"      = "postgres"
          "namespace" = "default"
        }
        spec = {
          "protocol" = "tcp"
        }
      }
      product-api = {
        metadata = {
          "name"      = "product-api"
          "namespace" = "default"
        }
        spec = {
          "protocol" = "http"
        }
      }
      payments = {
        metadata = {
          "name"      = "payments"
          "namespace" = "default"
        }
        spec = {
          "protocol" = "http"
        }
      }
      #      nginx = {}
      #      ingress = {}
    }
  }
}

variable "lambda_payments_path" {
  type        = string
  description = "Path to the HashiCups payments zip file for lambda"
}
