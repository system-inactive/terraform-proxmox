resource "proxmox_cloud_init_disk" "ci" {
  for_each = var.VMs
  name     = each.key
  pve_node = each.value["target_node"]
  storage  = "local"

  meta_data = yamlencode({
    instance_id    = sha256(each.key)
    local-hostname = each.key
  })

  user_data = join("\n", ["#cloud-config",
    yamlencode({
      packages = ["qemu-guest-agent"]
      runcmd   = ["systemctl enable --now qemu-guest-agent"]
      groups = [
        "sudo"
      ],
      users = ["default",
        {
          name        = each.value["username"]
          sudo        = "ALL=(ALL) NOPASSWD:ALL"
          lock_passwd = false
          passwd      = each.value["passwd"]
          shell       = "/bin/bash"
          ssh_authorized_keys = [
            for s in each.value["ssh_key"] : s
          ]
        }
      ]
    })
  ])

  network_config = yamlencode({
    network = {
      version = 2
      ethernets = {
        id0 = {
          match = {
            name = "ens*"
          }
          wakeonlan = true
          dhcp4     = true
        }
      }
    }
  })

}
