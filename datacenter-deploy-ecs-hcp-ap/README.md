## Admin Partitions with Consul on ECS and HCP Consul.

Refer to the Learn tutorial to use this terraform code.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >3.0.0 |
| <a name="requirement_consul"></a> [consul](#requirement\_consul) | ~> 2.15.1 |
| <a name="requirement_hcp"></a> [hcp](#requirement\_hcp) | ~> 0.14.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.10.0 |
| <a name="provider_hcp"></a> [hcp](#provider\_hcp) | 0.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | registry.terraform.io/terraform-aws-modules/vpc/aws | 2.78.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.acl_controllers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.clusters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_policy.hashicups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.hashicups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.hashicups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.example_client_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.hashicups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.hashicups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route.private_to_hvn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_to_hvn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_secretsmanager_secret.bootstrap_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.consul_ca_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.gossip_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.bootstrap_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.consul_ca_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.gossip_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.example_client_app_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress_from_client_alb_to_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_peering_connection_accepter.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [hcp_aws_network_peering.default](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/aws_network_peering) | resource |
| [hcp_consul_cluster.example](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/consul_cluster) | resource |
| [hcp_hvn.server](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/hvn) | resource |
| [hcp_hvn_route.peering_route](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/hvn_route) | resource |
| [random_id.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_security_group.vpc_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_cidrs"></a> [cluster\_cidrs](#input\_cluster\_cidrs) | VPC settings for this tutorial | `any` | <pre>{<br>  "ecs_cluster": {<br>    "cidr_block": "10.0.0.0/16",<br>    "name": "ecs_cluster",<br>    "private_subnets": [<br>      "10.0.1.0/24",<br>      "10.0.2.0/24",<br>      "10.0.3.0/24"<br>    ],<br>    "public_subnets": [<br>      "10.0.4.0/24",<br>      "10.0.5.0/24",<br>      "10.0.6.0/24"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_ecs_ap_globals"></a> [ecs\_ap\_globals](#input\_ecs\_ap\_globals) | n/a | `map` | <pre>{<br>  "acl_controller": {<br>    "logs_prefix": "acl",<br>    "prefix": "ap"<br>  },<br>  "admin_partitions_identifiers": {<br>    "partition-one": "default",<br>    "partition-two": "part2"<br>  },<br>  "base_cloudwatch_path": {<br>    "hashicups": "/hashicups/ecs"<br>  },<br>  "cloudwatch_config": {<br>    "create_groups": "true",<br>    "log_driver": "awslogs"<br>  },<br>  "consul_enterprise_image": {<br>    "enterprise_latest": "public.ecr.aws/hashicorp/consul-enterprise:1.11.4-ent",<br>    "enterprise_previous": "public.ecr.aws/hashicorp/consul-enterprise:1.11.3-ent",<br>    "opensource_latest": "public.ecr.aws/hashicorp/consul-enterprise:1.11.4",<br>    "opensource_previous": "public.ecr.aws/hashicorp/consul-enterprise:1.11.3"<br>  },<br>  "ecs_capacity_providers": [<br>    "FARGATE"<br>  ],<br>  "ecs_clusters": {<br>    "one": {<br>      "name": "clust1"<br>    },<br>    "two": {<br>      "name": "clust2"<br>    }<br>  },<br>  "enable_admin_partitions": {<br>    "enabled": true,<br>    "not_enabled": false<br>  },<br>  "global_prefix": "ap",<br>  "namespace_identifiers": {<br>    "global": "default"<br>  },<br>  "task_families": {<br>    "frontend": "frontend",<br>    "payments": "payments",<br>    "postgres": "postgres",<br>    "product-api": "product-api",<br>    "public-api": "public-api"<br>  }<br>}</pre> | no |
| <a name="input_hashicups_settings_private"></a> [hashicups\_settings\_private](#input\_hashicups\_settings\_private) | Settings for hashicups services deployed to default partition | `any` | <pre>[<br>  {<br>    "environment": [<br>      {<br>        "name": "DB_CONNECTION",<br>        "value": "host=localhost port=5432 user=postgres password=password dbname=products sslmode=disable"<br>      },<br>      {<br>        "name": "METRICS_ADDRESS",<br>        "value": ":9103"<br>      },<br>      {<br>        "name": "BIND_ADDRESS",<br>        "value": ":9090"<br>      }<br>    ],<br>    "image": "hashicorpdemoapp/product-api:v0.0.21",<br>    "name": "product-api",<br>    "portMappings": [<br>      {<br>        "containerPort": 9090,<br>        "hostPort": 9090,<br>        "protocol": "tcp"<br>      }<br>    ],<br>    "upstreams": [<br>      {<br>        "destinationName": "postgres",<br>        "destinationNamespace": "default",<br>        "destinationPartition": "default",<br>        "localBindPort": 5432<br>      }<br>    ],<br>    "volumes": []<br>  },<br>  {<br>    "environment": [],<br>    "image": "hashicorpdemoapp/payments:v0.0.16",<br>    "name": "payments",<br>    "portMappings": [<br>      {<br>        "containerPort": 1800,<br>        "hostPort": 1800,<br>        "protocol": "tcp"<br>      }<br>    ],<br>    "upstreams": []<br>  },<br>  {<br>    "environment": [<br>      {<br>        "name": "POSTGRES_DB",<br>        "value": "products"<br>      },<br>      {<br>        "name": "POSTGRES_USER",<br>        "value": "postgres"<br>      },<br>      {<br>        "name": "POSTGRES_PASSWORD",<br>        "value": "password"<br>      }<br>    ],<br>    "image": "hashicorpdemoapp/product-api-db:v0.0.21",<br>    "name": "postgres",<br>    "portMappings": [<br>      {<br>        "containerPort": 5432,<br>        "hostPort": 5432,<br>        "protocol": "tcp"<br>      }<br>    ],<br>    "upstreams": []<br>  }<br>]</pre> | no |
| <a name="input_hashicups_settings_public"></a> [hashicups\_settings\_public](#input\_hashicups\_settings\_public) | Settings for HashiCups services exposed to the internet | `any` | <pre>[<br>  {<br>    "environment": [],<br>    "image": "hashicorpdemoapp/frontend:v1.0.3",<br>    "name": "frontend",<br>    "portMappings": [<br>      {<br>        "containerPort": 3000,<br>        "hostPort": 3000,<br>        "protocol": "tcp"<br>      }<br>    ],<br>    "upstreams": [<br>      {<br>        "destinationName": "public-api",<br>        "destinationNamespace": "default",<br>        "destinationPartition": "part2",<br>        "localBindPort": 8081<br>      }<br>    ]<br>  },<br>  {<br>    "environment": [<br>      {<br>        "name": "BIND_ADDRESS",<br>        "value": ":8081"<br>      },<br>      {<br>        "name": "PRODUCT_API_URI",<br>        "value": "http://localhost:9090"<br>      },<br>      {<br>        "name": "PAYMENT_API_URI",<br>        "value": "http://localhost:1800"<br>      }<br>    ],<br>    "image": "hashicorpdemoapp/public-api:v0.0.6",<br>    "name": "public-api",<br>    "portMappings": [<br>      {<br>        "containerPort": 8081,<br>        "hostPort": 8081,<br>        "protocol": "tcp"<br>      }<br>    ],<br>    "upstreams": [<br>      {<br>        "destinationName": "product-api",<br>        "destinationNamespace": "default",<br>        "destinationPartition": "default",<br>        "localBindPort": 9090<br>      },<br>      {<br>        "destinationName": "payments",<br>        "destinationNamespace": "default",<br>        "destinationPartition": "default",<br>        "localBindPort": 1800<br>      }<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_hcp_datacenter_name"></a> [hcp\_datacenter\_name](#input\_hcp\_datacenter\_name) | The name of datacenter the Consul cluster belongs to | `string` | `"dc1"` | no |
| <a name="input_hvn_settings"></a> [hvn\_settings](#input\_hvn\_settings) | Settings for the HCP HVN | `any` | <pre>{<br>  "cidr_block": "172.25.16.0/20",<br>  "cloud_provider": {<br>    "aws": "aws"<br>  },<br>  "name": {<br>    "main-hvn": "main-hvn"<br>  },<br>  "region": {<br>    "us-east-1": "us-east-1"<br>  }<br>}</pre> | no |
| <a name="input_iam_action_type"></a> [iam\_action\_type](#input\_iam\_action\_type) | Actions required for IAM roles in this tutorial | `map(string)` | <pre>{<br>  "assume_role": "sts:AssumeRole"<br>}</pre> | no |
| <a name="input_iam_actions_allow"></a> [iam\_actions\_allow](#input\_iam\_actions\_allow) | What resources an IAM role is accessing in this tutorial | `map(any)` | <pre>{<br>  "elastic_load_balancer": [<br>    "elasticloadbalancing:*"<br>  ],<br>  "logging_create_and_put": [<br>    "logs:CreateLogGroup",<br>    "logs:CreateLogStream",<br>    "logs:PutLogEvent"<br>  ],<br>  "secrets_manager_get": [<br>    "secretsmanager:GetSecretValue"<br>  ]<br>}</pre> | no |
| <a name="input_iam_effect"></a> [iam\_effect](#input\_iam\_effect) | Allow or Deny for IAM policies | `map(string)` | <pre>{<br>  "allow": "Allow",<br>  "deny": "Deny"<br>}</pre> | no |
| <a name="input_iam_logs_actions_allow"></a> [iam\_logs\_actions\_allow](#input\_iam\_logs\_actions\_allow) | n/a | `list` | <pre>[<br>  "logs:CreateLogGroup",<br>  "logs:CreateLogStream",<br>  "logs:PutLogEvent"<br>]</pre> | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Base name of the IAM role to create in this tutorial | `string` | `"hashicups"` | no |
| <a name="input_iam_service_principals"></a> [iam\_service\_principals](#input\_iam\_service\_principals) | Names of the Services Principals this tutorial needs | `map(string)` | <pre>{<br>  "ecs": "ecs.amazonaws.com",<br>  "ecs_tasks": "ecs-tasks.amazonaws.com"<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_target_group_settings"></a> [target\_group\_settings](#input\_target\_group\_settings) | Load Balancer target groups for HashiCups services exposed to internet | `any` | <pre>{<br>  "elb": {<br>    "services": [<br>      {<br>        "deregistration_delay": 30,<br>        "health": {<br>          "healthy_threshold": 2,<br>          "interval": 30,<br>          "path": "/",<br>          "timeout": 29,<br>          "unhealthy_threshold": 2<br>        },<br>        "name": "frontend",<br>        "port": "80",<br>        "protocol": "HTTP",<br>        "service_type": "http",<br>        "target_group_type": "ip"<br>      },<br>      {<br>        "deregistration_delay": 30,<br>        "health": {<br>          "healthy_threshold": 2,<br>          "interval": 30,<br>          "path": "/",<br>          "port": "8081",<br>          "timeout": 29,<br>          "unhealthy_threshold": 2<br>        },<br>        "name": "public-api",<br>        "port": "8081",<br>        "protocol": "HTTP",<br>        "service_type": "http",<br>        "target_group_type": "ip"<br>      }<br>    ]<br>  }<br>}</pre> | no |

## Outputs

No outputs.
