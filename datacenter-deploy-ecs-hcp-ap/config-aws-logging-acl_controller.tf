# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_cloudwatch_log_group" "acl_controllers" {
  for_each = aws_ecs_cluster.clusters
  name     = "${local.acl_controller_log_path_base}/${each.value.name}"
}