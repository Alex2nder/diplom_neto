resource "yandex_compute_snapshot_schedule" "web" {
  count = 2
  name = "web-${count.index + 1}-snapshot"
  
  schedule_policy {
    expression = "0 1 * * *" # Ежедневно в 01:00
  }

  snapshot_count = 7 # Хранить 7 последних снапшотов
  
  disk_ids = [
    yandex_compute_instance.web[count.index].boot_disk.0.disk_id
  ]
}
