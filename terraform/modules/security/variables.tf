variable "suffix" {
  description = "Random suffix for resource names"
  type        = string
}
variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}
variable "bastion_ssh_cidr" {
  description = "CIDR block allowed to access bastion SSH"
  type        = string
}
variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}
variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
}
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}