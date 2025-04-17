output "bastion_sg_id" {
  value = yandex_vpc_security_group.bastion.id
}

output "alb_sg_id" {
  value = yandex_vpc_security_group.alb.id
}

output "web_sg_id" {
  value = yandex_vpc_security_group.web.id
}

output "zabbix_sg_id" {
  value = yandex_vpc_security_group.zabbix.id
}