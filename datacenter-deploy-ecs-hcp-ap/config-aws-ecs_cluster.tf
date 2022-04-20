resource "aws_ecs_cluster" "clusters" {
  for_each = { for cluster in var.ecs_ap_globals.ecs_clusters : cluster.name => cluster }
  name     = each.value.name
  #capacity_providers = var.ecs_ap_globals.ecs_capacity_providers
  ## Partial for aws_ecs_cluster to enable SSM
  #  configuration {
  #    execute_command_configuration {
  #      kms_key_id = aws_kms_key.this.key_id
  #      logging = "OVERRIDE"
  #      log_configuration {
  #        cloud_watch_log_group_name = local.private_services_log_path
  #      }
  #    }
  #  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  for_each           = aws_ecs_cluster.clusters
  cluster_name       = each.value.name
  capacity_providers = ["FARGATE"]
}

resource "aws_kms_key" "this" {
  description             = "for ecs cluster"
  deletion_window_in_days = "7"
}