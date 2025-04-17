resource "yandex_alb_target_group" "web" {
  name      = "web-target-group"
  folder_id = var.folder_id

  target {
    subnet_id = var.subnet_id
    ip_address = "10.0.1.10"
  }

  target {
    subnet_id = var.subnet_id
    ip_address = "10.0.1.11"
  }
}

resource "yandex_alb_backend_group" "web" {
  name      = "web-backend-group"
  folder_id = var.folder_id

  http_backend {
    name             = "web-backend"
    weight           = 100
    target_group_ids = [yandex_alb_target_group.web.id]
  }
}

resource "yandex_alb_http_router" "web" {
  name      = "web-http-router"
  folder_id = var.folder_id
}

resource "yandex_alb_load_balancer" "web" {
  name      = "web-load-balancer"
  folder_id = var.folder_id
  network_id = var.network_id

  allocation_policy {
    location {
      subnet_id = var.subnet_id
      zone_id   = "ru-central1-a"
    }
  }

  listener {
    name = "web-listener"

    endpoint {
      address {
        external_ipv4_address {
          address = "auto"
        }
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}

variable "folder_id" {
  type        = string
  description = "ID of the folder where resources will be created"
}

variable "yc_token" {
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  type        = string
}

variable "ssh_public_key" {
  type        = string
}
