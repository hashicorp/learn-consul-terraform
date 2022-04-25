resource "random_id" "random" {
  byte_length = 2
}

variable "ecs_ap_globals" {
  default = {
    global_prefix = "ap",
    acl_controller = {
      prefix      = "ap"
      logs_prefix = "acl"
    },
    namespace_identifiers = {
      global = "default"
    },
    admin_partitions_identifiers = {
      partition-one = "default"
      partition-two = "part2"
    },
    task_families = {
      postgres    = "postgres"
      public-api  = "public-api"
      product-api = "product-api"
      payments    = "payments"
      frontend    = "frontend"
    },
    enable_admin_partitions = {
      enabled     = true
      not_enabled = false
    },
    consul_enterprise_image = {
      enterprise_latest   = "public.ecr.aws/hashicorp/consul-enterprise:1.11.4-ent"
    },
    cloudwatch_config = {
      log_driver    = "awslogs"
      create_groups = "true"
    },
    base_cloudwatch_path = {
      hashicups = "/hashicups/ecs"
    },
    ecs_clusters = {
      one = {
        name = "clust1"
      }
      two = {
        name = "clust2"
      }
    },
    ecs_capacity_providers = ["FARGATE"]
  }
}

variable "region" {
  type        = string
  description = "AWS region."
  default     = "us-east-1"
}

variable "hcp_datacenter_name" {
  type        = string
  description = "The name of datacenter the Consul cluster belongs to"
  default     = "dc1"
}

variable "hashicups_settings_private" {
  type        = any
  description = "Settings for hashicups services deployed to default partition"
  default = [
    {
      name  = "product-api"
      image = "hashicorpdemoapp/product-api:v0.0.21"
      environment = [{
        name  = "DB_CONNECTION"
        value = "host=localhost port=5432 user=postgres password=password dbname=products sslmode=disable"
        },
        {
          name  = "METRICS_ADDRESS"
          value = ":9103"
        },
        {
          name  = "BIND_ADDRESS"
          value = ":9090"
      }]
      portMappings = [{
        protocol      = "tcp"
        containerPort = 9090
        hostPort      = 9090
      }]
      upstreams = [
        {

          destinationName      = "postgres"
          localBindPort        = 5432
          destinationNamespace = "default"
          destinationPartition = "default"
        },
      ],
      volumes = []
    },
    {
      name  = "payments"
      image = "hashicorpdemoapp/payments:v0.0.16"
      portMappings = [{
        protocol      = "tcp"
        containerPort = 1800
        hostPort      = 1800
      }]
      upstreams   = []
      environment = []
    },
    {
      name  = "postgres"
      image = "hashicorpdemoapp/product-api-db:v0.0.21"
      environment = [{
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
      }]
      portMappings = [{
        protocol      = "tcp"
        containerPort = 5432
        hostPort      = 5432
      }]
      upstreams = []
    },

  ]
}

variable "hashicups_settings_public" {
  type        = any
  description = "Settings for HashiCups services exposed to the internet"
  default = [
    {
      name  = "frontend"
      image = "hashicorpdemoapp/frontend:v1.0.3"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ],
      upstreams = [
        {
          destinationName      = "public-api"
          localBindPort        = 8081
          destinationNamespace = "default"
          destinationPartition = "part2"
        }
      ],
      environment = []
    },
    {
      name  = "public-api"
      image = "hashicorpdemoapp/public-api:v0.0.6"
      environment = [{
        # ECS only suports container/host port equality. Since payments also uses 8080, switch this to 8081.
        # Ref: https://github.com/hashicorp-demoapp/public-api/blob/a576419df268b74966c4dfdb90d653f498026d6d/main.go#L30
        name  = "BIND_ADDRESS"
        value = ":8081"
        },
        {
          name  = "PRODUCT_API_URI"
          value = "http://localhost:9090"
        },
        {
          name  = "PAYMENT_API_URI"
          value = "http://localhost:1800"
      }]
      portMappings = [{
        protocol      = "tcp"
        containerPort = 8081
        hostPort      = 8081
      }]
      upstreams = [{
        destinationName      = "product-api"
        destinationNamespace = "default"
        destinationPartition = "default"
        localBindPort        = 9090
        },
        {
          destinationName      = "payments"
          destinationNamespace = "default"
          destinationPartition = "default"
          localBindPort        = 1800
      }]
    }
  ]
}

variable "hvn_settings" {
  type        = any
  description = "Settings for the HCP HVN"
  default = {
    name = {
      main-hvn = "main-hvn"
    }
    cloud_provider = {
      aws = "aws"
    }
    region = {
      us-east-1 = "us-east-1"
    }
    cidr_block = "172.25.16.0/20"
  }
}

variable "target_group_settings" {
  type        = any
  description = "Load Balancer target groups for HashiCups services exposed to internet"
  default = {
    elb = {
      services = [
        {
          name                 = "frontend"
          service_type         = "http"
          protocol             = "HTTP"
          target_group_type    = "ip"
          port                 = "80"
          deregistration_delay = 30
          health = {
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 30
            timeout             = 29
            path                = "/"
          }
        },
        {
          name                 = "public-api"
          service_type         = "http"
          protocol             = "HTTP"
          target_group_type    = "ip"
          port                 = "8081"
          deregistration_delay = 30
          health = {
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 30
            timeout             = 29
            path                = "/"
            port                = "8081"
          },
        },
      ]
    }
  }
}

variable "cluster_cidrs" {
  type        = any
  description = "VPC settings for this tutorial"
  default = {
    ecs_cluster = {
      name            = "ecs_cluster"
      cidr_block      = "10.0.0.0/16"
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    },
  }
}

variable "iam_service_principals" {
  type        = map(string)
  description = "Names of the Services Principals this tutorial needs"
  default = {
    ecs_tasks = "ecs-tasks.amazonaws.com"
    ecs       = "ecs.amazonaws.com"
  }
}

variable "iam_role_name" {
  type        = string
  description = "Base name of the IAM role to create in this tutorial"
  default     = "hashicups"
}

variable "iam_effect" {
  type        = map(string)
  description = "Allow or Deny for IAM policies"
  default = {
    allow = "Allow"
    deny  = "Deny"
  }
}

variable "iam_action_type" {
  type        = map(string)
  description = "Actions required for IAM roles in this tutorial"
  default = {
    assume_role = "sts:AssumeRole"
  }
}

variable "iam_actions_allow" {
  type        = map(any)
  description = "What resources an IAM role is accessing in this tutorial"
  default = {
    secrets_manager_get = ["secretsmanager:GetSecretValue"]
    logging_create_and_put = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    "logs:PutLogEvent"]
    elastic_load_balancer = ["elasticloadbalancing:*"]

  }
}

variable "iam_logs_actions_allow" {
  default = [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvent"
  ]
}
