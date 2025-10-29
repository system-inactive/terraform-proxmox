resource "proxmox_vm_qemu" "pxe-example" {
  depends_on       = [time_sleep.wait_5s]
  for_each         = var.VMs
  name             = each.key
  agent            = 1
  skip_ipv6        = true
  automatic_reboot = false
  balloon          = 0
  bios             = "seabios"
  tags = join(",", [
    for t in each.value["tags"] : t
  ])
  cpu {
    type    = each.value.cpu.type
    sockets = each.value.cpu.sockets
    cores   = each.value.cpu.cores
    numa    = true
  }
  define_connection_info = true
  force_create           = false
  hotplug                = "disk,usb,network,memory"
  kvm                    = true
  memory                 = each.value.memory
  onboot                 = true
  vm_state               = each.value.vm_state
  qemu_os                = "l26"
  scsihw                 = "virtio-scsi-pci"
  protection             = false
  tablet                 = true
  target_node            = each.value.target_node
  full_clone             = false
  os_type                = "cloud-init"
  disks {
    ide {
      ide0 {
        cdrom {
          iso = proxmox_cloud_init_disk.ci[each.key].id
        }
      }
    }
  }

  network {
    id        = each.value.network.id
    bridge    = each.value.network.bridge
    firewall  = each.value.network.firewall
    link_down = each.value.network.link_down
    model     = each.value.network.model
    tag       = each.value.network.tag
  }

  smbios {
    family       = "VM"
    manufacturer = "Hashibrown"
    product      = "Terraform"
    sku          = md5(each.key)
    version      = "v1.0"
    serial       = "ABC123"
  }
  lifecycle {
    ignore_changes = [
      disks, default_ipv4_address, ssh_host, ssh_port, vm_state,
    ]
  }
}
