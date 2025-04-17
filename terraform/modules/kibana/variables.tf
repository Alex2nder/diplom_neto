variable "network_id" {
  type        = string
  description = "ID of the VPC network"
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet"
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

variable "suffix" {
  description = "Random suffix for resource names"
  type        = string
}
