output "web_instance_ids" {
  value       = [for instance in yandex_compute_instance.web : instance.id]
  description = "IDs of web instances"
}

output "web_ips" {
  value = yandex_compute_instance.web[*].network_interface[0].ip_address
}

output "web_fqdn" {
  value = yandex_compute_instance.web[*].fqdn
}

output "web_disk_ids" {
  value = yandex_compute_instance.web[*].boot_disk[0].disk_id
}