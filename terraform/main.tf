terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.138.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

variable "bastion_ssh_cidr" {
  type        = string
  description = "CIDR block allowed to access bastion SSH"
  default     = "0.0.0.0/0"
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token from vault.yml"
  sensitive   = true
}

module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source           = "./modules/security"
  network_id       = module.vpc.network_id
  bastion_ssh_cidr = var.bastion_ssh_cidr
  folder_id        = var.folder_id
  yc_token         = var.yc_token
  cloud_id         = var.cloud_id
  ssh_public_key   = var.ssh_public_key
  suffix           = random_string.suffix.result
}

module "web" {
  source              = "./modules/web"
  network_id          = module.vpc.network_id
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
  folder_id           = var.folder_id
  ssh_public_key      = var.ssh_public_key
  yc_token            = var.yc_token
  cloud_id            = var.cloud_id
  web_sg_id           = module.security.web_sg_id
}

module "alb" {
  source              = "./modules/alb"
  network_id          = module.vpc.network_id
  public_subnet_id    = module.vpc.public_subnet_id
  public_subnet_b_id  = module.vpc.public_subnet_b_id  # Добавлено
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_b_id = module.vpc.private_subnet_b_id
  alb_sg_id           = module.security.alb_sg_id
  web_ips             = module.web.web_ips
  depends_on          = [module.web]
}

module "zabbix_server" {
  source           = "./modules/zabbix_server"
  public_subnet_id = module.vpc.public_subnet_id
  network_id       = module.vpc.network_id
  folder_id        = var.folder_id
  ssh_public_key   = var.ssh_public_key
  zabbix_sg_id     = module.security.zabbix_sg_id
}

module "kibana" {
  source           = "./modules/kibana"
  network_id       = module.vpc.network_id
  suffix           = random_string.suffix.result
  public_subnet_id = module.vpc.public_subnet_id
  folder_id        = var.folder_id
  ssh_public_key   = var.ssh_public_key
  yc_token         = var.yc_token
  cloud_id         = var.cloud_id
}

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
    preemptible = true
  }
}

module "elasticsearch" {
  source            = "./modules/elasticsearch"
  folder_id         = var.folder_id
  network_id        = module.vpc.network_id
  suffix            = random_string.suffix.result
  subnet_id         = module.vpc.private_subnet_a_id
  ssh_public_key    = var.ssh_public_key
  yc_token          = var.yc_token
  cloud_id          = var.cloud_id
}

resource "yandex_compute_snapshot_schedule" "all_vms" {
  name             = "all-vms-snapshot-schedule"
  retention_period = "168h"
  schedule_policy {
    expression = "0 0 * * *"
  }
  snapshot_spec {
    description = "Daily snapshot"
  }
  disk_ids = [
    module.zabbix_server.zabbix.boot_disk[0].disk_id,
    module.kibana.kibana.boot_disk[0].disk_id,
    module.elasticsearch.elasticsearch.boot_disk[0].disk_id,
    module.web.web_disk_ids[0],
    module.web.web_disk_ids[1],
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
  ]
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
output "inventory" {
  value = {
    balancer_ip = module.alb.load_balancer_ip
    bastion = {
      name         = "bastion"
      ansible_host = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
      public_ip    = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
      ssh_args     = ""
    }
    internal_servers = {
      web_servers = [
        {
          name         = "web-instance-1"
          ansible_host = module.web.web_ips[0]  # Внутренний IP: 10.0.2.7
          ssh_args     = "-o ProxyCommand='ssh -i /home/alexander/.ssh/id_rsa -W %h:%p ubuntu@{{ bastion_public_ip }}'"
        },
        {
          name         = "web-instance-2"
          ansible_host = module.web.web_ips[1]  # Внутренний IP: 10.0.3.21
          ssh_args     = "-o ProxyCommand='ssh -i /home/alexander/.ssh/id_rsa -W %h:%p ubuntu@{{ bastion_public_ip }}'"
        }
      ]
      zabbix = [
        {
          name         = "zabbix-server"
          ansible_host = module.zabbix_server.zabbix_ip  # Внутренний IP: 10.0.1.28
          public_ip    = module.zabbix_server.zabbix.network_interface[0].nat_ip_address
          ssh_args     = "-o ProxyCommand='ssh -i /home/alexander/.ssh/id_rsa -W %h:%p ubuntu@{{ bastion_public_ip }}'"
        }
      ]
      elasticsearch = [
        {
          name         = "elasticsearch-server"
          ansible_host = module.elasticsearch.elasticsearch_ip  # Внутренний IP: 10.0.1.211
          ssh_args     = "-o ProxyCommand='ssh -i /home/alexander/.ssh/id_rsa -W %h:%p ubuntu@{{ bastion_public_ip }}'"
        }
      ]
      kibana = [
        {
          name         = "kibana-server"
          ansible_host = module.kibana.kibana_ip  # Внутренний IP: 10.0.1.24
          public_ip    = module.kibana.kibana.network_interface[0].nat_ip_address
          ssh_args     = "-o ProxyCommand='ssh -i /home/alexander/.ssh/id_rsa -W %h:%p ubuntu@{{ bastion_public_ip }}'"
        }
      ]
    }
  }
}