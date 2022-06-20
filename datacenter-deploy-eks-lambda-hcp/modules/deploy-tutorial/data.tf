data "aws_caller_identity" "current" {}

data "aws_availability_zones" "this" {
  all_availability_zones = true
  filter {
    name   = "region-name"
    values = [var.tutorial_config.aws_region]
  }
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
