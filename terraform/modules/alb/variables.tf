variable "network_id" {
  type        = string
  description = "ID of the network to attach the ALB to"
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet for the ALB"
}

variable "alb_sg_id" {
  type        = string
  description = "ID of the security group for the ALB"
}

variable "web_ips" {
  type        = list(string)
  description = "List of IP addresses of web instances"
}

variable "private_subnet_a_id" {
  type        = string
  description = "ID of the private subnet in zone A"
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet in ru-central1-b"
  type        = string
}