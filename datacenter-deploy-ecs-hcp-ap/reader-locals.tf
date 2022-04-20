# Note to Reader: These values are meant to make the other code in this project more readable. You will not need to
# modify any of the values in this file. :)

locals {
    tasks = {
      public = [
      for t in var.hashicups_settings_public : t.name
      ]
      private = [
      for t in var.hashicups_settings_private : t.name
      ]
    }

    requires_target_group_association = [
    for c in var.hashicups_settings_public : c if c.name == var.ecs_ap_globals.task_families.frontend || c.name == var.ecs_ap_globals.task_families.public-api
    ]

    load_balancer_public_apps_config = [
    for n in local.requires_target_group_association : {
      container_name = n.name
      container_port = n.portMappings[0].containerPort
      target_group   = aws_lb_target_group.hashicups[n.name].arn
      }
    ]
}