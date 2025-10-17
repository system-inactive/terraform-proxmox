resource "time_sleep" "wait_5s" {
  depends_on      = [proxmox_cloud_init_disk.ci]
  create_duration = "10s"
}
