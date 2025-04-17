resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-instance-${count.index + 1}"
  hostname    = "web-instance-${count.index + 1}"
  zone        = count.index == 0 ? "ru-central1-a" : "ru-central1-b"
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
    }
  }

  network_interface {
    subnet_id          = count.index == 0 ? var.private_subnet_a_id : var.private_subnet_b_id
    nat                = false
    security_group_ids = [var.web_sg_id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true  # Изменено с false на true
  }
}