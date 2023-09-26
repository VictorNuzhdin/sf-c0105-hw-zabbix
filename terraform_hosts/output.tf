## v1
output "yaml_output" {
  value = <<-EOT
  hosts:
    ${yandex_compute_instance.host1.name}:
      ipv4_internal: "${yandex_compute_instance.host1.network_interface.0.ip_address}"
      ipv4_external: "${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
      host_weblink1: "http://${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
      host_weblink2: "http://${yandex_compute_instance.host1.name}.dotspace.ru"
    ${yandex_compute_instance.host2.name}:
      ipv4_internal: "${yandex_compute_instance.host2.network_interface.0.ip_address}"
      ipv4_external: "${yandex_compute_instance.host2.network_interface.0.nat_ip_address}"
      host_weblink1: "http://${yandex_compute_instance.host2.network_interface.0.nat_ip_address}"
      host_weblink2: "http://${yandex_compute_instance.host2.name}.dotspace.ru"
  EOT
}
/**
Outputs:

yaml_output = <<EOT
hosts:
  host1:
    ipv4_internal: "10.0.20.3"
    ipv4_external: "84.252.142.140"
  host2:
    ipv4_internal: "10.0.20.4"
    ipv4_external: "51.250.22.48"

EOT
*/

## terraform refresh
## terraform output -raw yaml_output
## terraform output -raw yaml_output > output.yaml
## cat output.yaml
/**
hosts:
  host1:
    ipv4_internal: "10.0.20.3"
    ipv4_external: "84.252.142.140"
  host2:
    ipv4_internal: "10.0.20.3"
    ipv4_external: "51.250.22.48"
*/
