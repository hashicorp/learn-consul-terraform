output "vpc_id" {
  default = module.vpc.vpc_id
}

output "public_subnets" {
  default = module.vpc.public_subnets
}

output "public_route_table_ids" {
  default = module.vpc.public_route_table_ids
}
