output "consul_values" {
  value     = module.tutorial_infrastructure.consul_values
  sensitive = true
}