resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = var.folder_id
  name       = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id = var.folder_id
  name       = "nat-route-table"
  network_id = var.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "private_subnet" {
  folder_id = var.folder_id
  name       = "private-subnet"
  v4_cidr_blocks = ["10.20.30.0/24"]
  zone        = "ru-central1-a"
  network_id = var.network_id
  route_table_id = yandex_vpc_route_table.rt.id
}
