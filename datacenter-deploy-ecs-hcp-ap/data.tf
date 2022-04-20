data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_caller_identity" "current" {}

data "aws_ecs_task_definition" "public_tasks" {
  for_each = toset(local.tasks.public)
  task_definition = each.value

  depends_on = [module.hashicups-tasks-public]
}

data "aws_ecs_task_definition" "private_tasks" {
  for_each        = toset(local.tasks.private)
  task_definition = each.value

  depends_on = [module.hashicups-tasks-private]
}

data "consul_services" "all" {
  query_options {
    namespace = local.namespace
  }
  depends_on = [aws_ecs_service.public_services, aws_ecs_service.private_services]
}

data "consul_service" "each" {
  for_each = toset(concat(local.tasks.public, local.tasks.private))
  name     = each.key
  query_options {
    wait_time = "1m"
  }
}

