variable "public_subnet_b_id" {
  type        = string
  description = "ID of the public subnet in ru-central1-b"
}

resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  dynamic "target" {
    for_each = var.web_ips
    content {
      ip_address = target.value
      subnet_id  = index(var.web_ips, target.value) == 0 ? var.private_subnet_a_id : var.private_subnet_b_id
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight           = 100
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 1
      healthcheck_port    = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-host"
  http_router_id = yandex_alb_http_router.web.id
  authority      = ["*"]

  route {
    name = "root"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name       = "web-balancer"
  network_id = var.network_id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = var.public_subnet_id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = var.public_subnet_b_id  # Используем новую подсеть
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }

  security_group_ids = [var.alb_sg_id]
}

output "load_balancer_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}