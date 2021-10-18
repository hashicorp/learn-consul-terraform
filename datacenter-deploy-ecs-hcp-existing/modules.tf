module "acl_controller" {
  source = "../modules/acl-controller"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-acl-controller"
    }
  }
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  consul_server_ca_cert_arn         = aws_secretsmanager_secret.consul_ca_cert.arn
  // consul_server_http_addr           = "https://${var.consul_cluster_ip}:8501"
  consul_server_http_addr           = "https://dc1.private.consul.98a0dcc3-5473-4e4d-a28e-6c343c498530.aws.hashicorp.cloud"
  ecs_cluster_arn                   = aws_ecs_cluster.this.arn
  region                            = var.region
  subnets                           = var.private_subnets_ids
  name_prefix                       = var.name
}

module "example_client_app" {
  source            = "../modules/mesh-task"
  family            = "${var.name}-example-client-app"
  port              = "9090"
  log_configuration = local.example_client_app_log_config
  container_definitions = [{
    name             = "example-client-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_client_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-client-app"
      },
      {
        name  = "UPSTREAM_URIS"
        value = "http://localhost:1234"
      }
    ]
    portMappings = [
      {
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destination_name = "${var.name}-example-server-app"
      local_bind_port  = 1234
    }
  ]
  // retry_join                     = var.consul_cluster_ip
  retry_join                     = "https://dc1.private.consul.98a0dcc3-5473-4e4d-a28e-6c343c498530.aws.hashicorp.cloud"
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = var.consul_datacenter
}

module "example_server_app" {
  source            = "../modules/mesh-task"
  family            = "${var.name}-example-server-app"
  port              = "9090"
  log_configuration = local.example_server_app_log_config
  container_definitions = [{
    name             = "example-server-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_server_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-server-app"
      }
    ]
  }]
  // retry_join                     = var.consul_cluster_ip
  retry_join                     = "https://dc1.private.consul.98a0dcc3-5473-4e4d-a28e-6c343c498530.aws.hashicorp.cloud"
  tls                            = true
  consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
  gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
  acls                           = true
  consul_client_token_secret_arn = module.acl_controller.client_token_secret_arn
  acl_secret_name_prefix         = var.name
  consul_datacenter              = var.consul_datacenter
}