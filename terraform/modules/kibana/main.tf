resource "yandex_compute_instance" "kibana" {
  name        = "kibana-server"
  hostname    = "kibana-server"
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
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  scheduling_policy {
    preemptible = true  # Перед сдачей заменить на false
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "kibana-sg-${var.suffix}"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Allow Kibana access from anywhere"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]  # Разрешаем доступ извне
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from bastion"
    port           = 22
    v4_cidr_blocks = ["10.0.1.0/24"]
  }

ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Agent traffic from internal VMs and public subnet"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    port           = 10051
  }

  # Правило для Zabbix: входящий трафик на порт 10050 от Zabbix-сервера
  ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Server to connect to agent on port 10050"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}