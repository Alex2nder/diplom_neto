output "web_instance_ip" {
  value = yandex_compute_instance.web.network_interface[0].ip_address
}
