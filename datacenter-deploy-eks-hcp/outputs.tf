# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "consul_ui_address" {
  value = hcp_consul_cluster.example.consul_public_endpoint_url
}