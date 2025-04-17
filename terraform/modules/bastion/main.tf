resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"
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
    subnet_id          = module.vpc.public_subnet_id
    nat                = true
    security_group_ids = [module.security.bastion_sg_id]
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  scheduling_policy {
    preemptible = true  # Перед сдачей заменить на false
  }
}