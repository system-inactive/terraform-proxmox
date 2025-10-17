resource "null_resource" "import_and_attach" {
  depends_on = [proxmox_vm_qemu.pxe-example]
  for_each   = proxmox_vm_qemu.pxe-example

  triggers = {
    vmid        = each.value.vmid
    import_from = var.VMs[each.key].import_from
    storage     = var.VMs[each.key].target_storage
  }
  provisioner "local-exec" {
    command = <<-EOT
    ssh -o StrictHostKeyChecking=no \
        ${var.pve_ssh_user}@${var.pve_host} \
          "sudo /usr/bin/pvesh create /nodes/${var.VMs[each.key].target_node}/qemu/${each.value.vmid}/status/stop || true"
    ssh -o StrictHostKeyChecking=no \
        ${var.pve_ssh_user}@${var.pve_host} "sudo /usr/bin/pvesh create /nodes/${var.VMs[each.key].target_node}/qemu/${each.value.vmid}/config \
          --scsi0 '${var.VMs[each.key].target_storage}:0,import-from=${var.VMs[each.key].import_from}'" \
          --boot order=scsi0
    ssh -o StrictHostKeyChecking=no  ${var.pve_ssh_user}@${var.pve_host} \
        "sudo /usr/bin/pvesh set /nodes/${var.VMs[each.key].target_node}/qemu/${each.value.vmid}/resize -disk scsi0 -size ${var.VMs[each.key].disk_size}"
    ssh -o StrictHostKeyChecking=no \
        ${var.pve_ssh_user}@${var.pve_host} \
          "sudo /usr/bin/pvesh create /nodes/${var.VMs[each.key].target_node}/qemu/${each.value.vmid}/status/start || true"
    EOT
  }
}
