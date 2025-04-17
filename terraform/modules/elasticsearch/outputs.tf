output "elasticsearch_disk_id" {
  value       = yandex_compute_instance.elasticsearch.boot_disk[0].disk_id
  description = "Disk ID of the Elasticsearch instance"
}

output "elasticsearch" {
  value       = yandex_compute_instance.elasticsearch
  description = "Elasticsearch compute instance"
}

output "elasticsearch_ip" {
  value       = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
  description = "Internal IP address of the Elasticsearch instance"
}

output "elasticsearch_id" {
  value       = yandex_compute_instance.elasticsearch.id
  description = "ID of the Elasticsearch instance"
}

output "elasticsearch_sg_id" {
  value       = yandex_vpc_security_group.elasticsearch.id
  description = "ID of the Elasticsearch security group"
}

output "elasticsearch_fqdn" {
  value = yandex_compute_instance.elasticsearch.fqdn
}