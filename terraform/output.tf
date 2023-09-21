output "vm1_srv_external_ip" {
  value       = "${yandex_compute_instance.host1.name}: ${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
  description = "The Name and public IP address of VM1 instance."
  sensitive   = false
}

output "vm1_srv_internal_ip" {
  value       = "${yandex_compute_instance.host1.name}: ${yandex_compute_instance.host1.network_interface.0.ip_address}"
  description = "The Name and internal IP address of VM1 instance."
  sensitive   = false
}

/*=EXAMPLE_OUTPUT:

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    Outputs:

    vm1_srv_external_ip = "srv: 158.160.78.4"
    vm1_srv_internal_ip = "srv: 10.0.10.13"
*/
