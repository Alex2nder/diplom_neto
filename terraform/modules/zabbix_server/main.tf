resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix-server"
  hostname    = "zabbix-server"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  folder_id   = var.folder_id
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8s3qh62qn5sqoemni6"
      size     = 10
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id          = var.public_subnet_id  # Оставляем публичную подсеть
    nat                = true                 # Включаем внешний IP
    security_group_ids = [var.zabbix_sg_id]
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  scheduling_policy {
    preemptible = true  # Перед сдачей заменить на false
  }
}

output "zabbix_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].ip_address
}

output "zabbix" {
  value = yandex_compute_instance.zabbix
}