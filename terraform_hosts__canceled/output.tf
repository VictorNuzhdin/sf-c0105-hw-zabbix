## v1
output "ig_hosts_ipv4_public" {
  #value = yandex_compute_instance_group.ig-1.instances.*.name
  value = yandex_compute_instance_group.ig-1.instances.*.network_interface.0.nat_ip_address
  description = "Instance Group Hosts public IPv4 addresses"
  sensitive   = false
}
/**
  $ terrafrotm refresh
  $ terrafrotm output

  Outputs:

  ig_hosts_ipv4_public = tolist([
    "158.160.69.43",
    "158.160.77.108",
  ])
*/
