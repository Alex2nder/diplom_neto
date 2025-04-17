output "kibana_disk_id" {
  value       = yandex_compute_instance.kibana.boot_disk[0].disk_id
  description = "Disk ID of the Kibana instance"
}

output "kibana" {
  value       = yandex_compute_instance.kibana
  description = "Kibana compute instance"
}

output "kibana_fqdn" {
  value       = yandex_compute_instance.kibana.fqdn
  description = "FQDN of the Kibana instance"
}

output "kibana_public_ip" {
  value       = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
  description = "Public IP address of the Kibana instance"
}

output "kibana_ip" {
  value       = yandex_compute_instance.kibana.network_interface[0].ip_address
  description = "Internal IP address of the Kibana instance"
}