# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_lb" "example_client_app" {
  internal           = false
  load_balancer_type = local.load_balancer_type
  name               = local.load_balancer_name
  subnets            = module.vpc.public_subnets
  security_groups = [
    aws_security_group.example_client_app_alb.id
  ]
}
resource "aws_lb_target_group" "hashicups" {
  for_each = { for service in var.target_group_settings.elb.services : service.name => service }

  vpc_id      = module.vpc.vpc_id
  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_group_type

  deregistration_delay = 10
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    port                = try(each.value.health.port, "traffic-port")
  }
}

resource "aws_lb_listener" "hashicups" {
  for_each = aws_lb_target_group.hashicups

  load_balancer_arn = aws_lb.example_client_app.arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    type             = local.lb_listener_type
    target_group_arn = each.value.arn
  }
}