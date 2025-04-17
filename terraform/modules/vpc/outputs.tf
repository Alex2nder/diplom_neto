output "network_id" {
  value = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  value = yandex_vpc_subnet.public.id
}

output "private_subnet_a_id" {
  value = yandex_vpc_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = yandex_vpc_subnet.private_b.id
}

output "public_subnet_b_id" {
  value = yandex_vpc_subnet.public_b.id
}