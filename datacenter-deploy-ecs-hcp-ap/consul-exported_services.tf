# Export Products API into part2 partition.
resource "consul_config_entry" "export_product_api_to_part2" {
  kind      = "exported-services"
  name      = var.ecs_ap_globals.admin_partitions_identifiers.partition-one
  partition = var.ecs_ap_globals.admin_partitions_identifiers.partition-one
  namespace = var.ecs_ap_globals.namespace_identifiers.global
  config_json = jsonencode({
    Services = [
      {
        Name = var.ecs_ap_globals.task_families.product-api
        Consumers = [
          {
            Partition = consul_admin_partition.partition-two.name
          }
        ]
      }
    ]
  })
  depends_on = [aws_ecs_service.public_services]
}

# Export Public API into default partition.
resource "consul_config_entry" "export_public_api_to_default" {
  kind      = "exported-services"
  name      = consul_admin_partition.partition-two.name
  partition = consul_admin_partition.partition-two.name
  namespace = var.ecs_ap_globals.namespace_identifiers.global
  config_json = jsonencode({
    Services = [
      {
        Name = var.ecs_ap_globals.task_families.public-api
        Consumers = [
          {
            Partition = var.ecs_ap_globals.admin_partitions_identifiers.partition-one
          }
        ]
      }
    ]
  })
  depends_on = [aws_ecs_service.public_services]
}
