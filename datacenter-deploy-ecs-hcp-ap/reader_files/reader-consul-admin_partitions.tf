resource "consul_admin_partition" "partition-two" {
  name        = local.admin_partitions.two
  description = "Admin Partition for public facing HashiCups services"

  depends_on = [hcp_consul_cluster.example]
}