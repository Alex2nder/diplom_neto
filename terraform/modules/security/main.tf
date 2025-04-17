# Security Group для бастион-хоста
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg-${var.suffix}"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from specified CIDR"
    port           = 22
    v4_cidr_blocks = [var.bastion_ssh_cidr] # Ограничение SSH-доступа по CIDR
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

# Security Group для Application Load Balancer
resource "yandex_vpc_security_group" "alb" {
  name       = "alb-sg-${var.suffix}"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "HTTP traffic"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Health checks from ALB"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для веб-серверов
resource "yandex_vpc_security_group" "web" {
  name       = "web-sg-${var.suffix}"
  network_id = var.network_id

  ingress {
    protocol          = "TCP"
    description       = "Allow HTTP from ALB"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
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

# Security Group для Zabbix-сервера
resource "yandex_vpc_security_group" "zabbix" {
  name       = "zabbix-sg-${var.suffix}"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix web access from anywhere"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Agent traffic from internal VMs and public subnet"
    port           = 10051
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from bastion"
    port           = 22
    v4_cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}