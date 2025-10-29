resource "null_resource" "import_and_attach" {
  for_each   = proxmox_vm_qemu.pxe-example
  depends_on = [ proxmox_vm_qemu.pxe-example ]

  #proxmox_vm_qemu.pxe-example

   triggers = {
    vmid        = tostring(each.value.vmid)
    import_from = var.VMs[each.key].import_from
    force_import = var.VMs[each.key].force_import
    storage     = var.VMs[each.key].target_storage
    disk_sha    = replace(trimspace(tostring(try(data.external.sha[each.key].result.sha, ""))), "\n","")
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-euo", "pipefail", "-c"]
    command = <<-EOT
      SSH='ssh -o StrictHostKeyChecking=no '"${var.pve_ssh_user}@${var.pve_host}"' sudo'
      TARGET_NODE="${var.VMs[each.key].target_node}"
      STORAGE="${var.VMs[each.key].target_storage}"
      VMID="${each.value.vmid}"
      IMPORT_FROM="${var.VMs[each.key].import_from}"
      DISK_SIZE="${var.VMs[each.key].disk_size}"
      FORCE_IMPORT="${var.VMs[each.key].force_import}"

      CHECK_DISK=$($SSH pvesh get /nodes/$TARGET_NODE/storage/$STORAGE/content --output-format json \
            | jq --arg v "$STORAGE:vm-$VMID-disk-0" '.[]|select(.volid==$v)')
      if [[ "$FORCE_IMPORT" == true ]]; then
          $SSH pvesh create /nodes/$TARGET_NODE/qemu/$VMID/status/stop || true
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config -delete scsi0
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config -delete unused0
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config \
          -scsi0 "$STORAGE:0,import-from=$IMPORT_FROM" \
          -scsihw virtio-scsi-pci
          echo "$IMPORT_FROM" > "$VMID".lastimport
      elif [[ -z "$CHECK_DISK" ]]; then
        $SSH pvesh create /nodes/$TARGET_NODE/qemu/$VMID/status/stop || true
        echo "[run] import-and-attach $IMPORT_FROM -> $STORAGE:scsi0"
        $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config \
          -scsi0 "$STORAGE:0,import-from=$IMPORT_FROM" \
          -scsihw virtio-scsi-pci
        echo "$IMPORT_FROM" > "$VMID".lastimport
      elif [[ $(cat $VMID.lastimport) != "$IMPORT_FROM" ]]; then
          echo "----- New image ----"
          $SSH pvesh create /nodes/$TARGET_NODE/qemu/$VMID/status/stop || true
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config -delete scsi0
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config -delete unused0
          $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config \
          -scsi0 "$STORAGE:0,import-from=$IMPORT_FROM" \
          -scsihw virtio-scsi-pci
          echo "$IMPORT_FROM" > "$VMID".lastimport
      else
        echo ----- Volume exists; skip import -----'
      fi

      # boot order
      $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/config -boot "order=scsi0"

      $SSH pvesh set /nodes/$TARGET_NODE/qemu/$VMID/resize -disk scsi0 -size "$DISK_SIZE"

      # start all vms
      $SSH pvesh create /nodes/$TARGET_NODE/qemu/$VMID/status/start || true

    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      VMID="${self.triggers.vmid}"
      rm -f "$VMID".lastimport
    EOT
  }
}
