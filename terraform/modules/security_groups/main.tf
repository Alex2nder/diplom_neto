variable "folder_id" {
  type        = string
  description = "ID of the folder"
}

variable "network_id" {
  type        = string
  description = "ID of the network"
}

variable "alb_sg_id" {
  type        = string
  description = "ID of the ALB security group"
}

variable "bastion_sg_id" {
  type        = string
  description = "ID of the bastion security group"
}

resource "yandex_vpc_security_group" "web_sg" {
  folder_id = var.folder_id
  name      = "web-sg"
  network_id = var.network_id

  ingress {
    protocol          = "TCP"
    port              = 80
    security_group_id = var.alb_sg_id
  }

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = var.bastion_sg_id
  }
}

resource "yandex_vpc_security_group" "ssh_sg" {
  folder_id = var.folder_id
  name      = "ssh-sg"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

