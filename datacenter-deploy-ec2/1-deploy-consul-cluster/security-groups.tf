# resource "aws_security_group" "example_client_app_alb" {
#   name   = "${var.name}-example-client-app-alb"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     description = "Access to example client application."
#     from_port   = 9090
#     to_port     = 9090
#     protocol    = "tcp"
#     cidr_blocks = ["${var.lb_ingress_ip}/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group_rule" "ingress_from_client_alb_to_ecs" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 65535
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.example_client_app_alb.id
#   security_group_id        = data.aws_security_group.vpc_default.id
# }

resource "aws_security_group" "consul" {
  name   = "${var.name}-consul-server"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.lb_ingress_ip}/32"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${var.lb_ingress_ip}/32"]
  }

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${var.lb_ingress_ip}/32"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}