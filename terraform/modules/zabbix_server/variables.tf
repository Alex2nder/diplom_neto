variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet"
}

variable "zabbix_sg_id" {
  type        = string
  description = "ID of the Zabbix security group"
}

variable "ssh_public_key" {
  type        = string
}

variable "folder_id" {
  type        = string
  description = "ID of the folder where resources will be created"
}

variable "network_id" {
  type        = string
  description = "ID of the network"
}
