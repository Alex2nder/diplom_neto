resource "yandex_compute_instance" "web" {
  name        = "web-server"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = "fd8s3qh62qn5sqoemni6"
      size     = 10
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = false
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
