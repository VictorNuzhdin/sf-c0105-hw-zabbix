## v1
output "ig_hosts_ipv4_public" {
  #value = yandex_compute_instance_group.ig-1.instances.*.name
  value = yandex_compute_instance_group.ig-1.instances.*.network_interface.0.nat_ip_address
  description = "Instance Group Hosts public IPv4 addresses"
  sensitive   = false
}
/**
  $ terraform refresh
  $ terraform output

  Outputs:

  ig_hosts_ipv4_public = tolist([
    "84.201.178.239",
    "84.201.179.226",
  ])
*/
