resource "consul_config_entry" "product-api" {
  kind = "service-defaults"
  name = data.consul_service.each["product-api"].name


  config_json = jsonencode({
    Protocol = local.consul_service_defaults_protocols.tcp
  })
}
