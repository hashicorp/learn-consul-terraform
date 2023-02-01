# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_iam_role" "hashicups" {
  for_each = { for cluster in var.ecs_ap_globals.ecs_clusters : cluster.name => cluster }
  name     = "${var.iam_role_name}-${each.value.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = var.iam_effect.allow
        Principal = {
          Service = var.iam_service_principals.ecs_tasks
        }
        Action = var.iam_action_type.assume_role
      },
      {
        Effect = var.iam_effect.allow
        Principal = {
          "AWS" = [local.ecs_service_role]
        }
        Action = var.iam_action_type.assume_role
      },
      {
        Effect = var.iam_effect.allow
        Principal = {
          Service = var.iam_service_principals.ecs
        }
        Action = var.iam_action_type.assume_role
      },
    ]
  })
}

resource "aws_iam_policy" "hashicups" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = var.iam_actions_allow.secrets_manager_get
        Effect = var.iam_effect.allow
        Resource = [
          aws_secretsmanager_secret.gossip_key.arn,
          aws_secretsmanager_secret.bootstrap_token.arn,
          aws_secretsmanager_secret.consul_ca_cert.arn,
          aws_lb.example_client_app.arn
        ]
      },
      {
        Action   = var.iam_actions_allow.logging_create_and_put
        Effect   = var.iam_effect.allow
        Resource = ["*"]
      },
      {
        Action = var.iam_actions_allow.elastic_load_balancer
        Effect = var.iam_effect.allow
        Resource = [
          aws_lb.example_client_app.arn
        ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "hashicups" {
  for_each   = aws_iam_role.hashicups
  policy_arn = aws_iam_policy.hashicups.arn
  role       = each.value.name
}
