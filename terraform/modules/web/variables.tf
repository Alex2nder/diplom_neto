variable "network_id" {
  type        = string
  description = "ID of the VPC network"
}

variable "private_subnet_a_id" {
  type        = string
  description = "ID of private subnet in zone A"
}

variable "private_subnet_b_id" {
  type        = string
  description = "ID of private subnet in zone B"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "web_sg_id" {
  type        = string
  description = "ID of the security group for web instances"
}