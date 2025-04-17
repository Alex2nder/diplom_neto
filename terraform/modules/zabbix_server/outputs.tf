output "zabbix_disk_id" {
  value = yandex_compute_instance.zabbix.boot_disk[0].disk_id
  description = "Disk ID of the Zabbix server instance"
}

output "zabbix_fqdn" {
  value = yandex_compute_instance.zabbix.fqdn
}

output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}