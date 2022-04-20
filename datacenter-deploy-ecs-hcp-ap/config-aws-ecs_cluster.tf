resource "aws_ecs_cluster" "clusters" {
  for_each = { for cluster in var.ecs_ap_globals.ecs_clusters : cluster.name => cluster }
  name     = each.value.name
}

# Passing the capacity_providers arg in aws_ecs_cluster is deprecated
# Creating a dedicated resource is the preferred path according the provider.
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  for_each           = aws_ecs_cluster.clusters
  cluster_name       = each.value.name
  capacity_providers = ["FARGATE"]
}