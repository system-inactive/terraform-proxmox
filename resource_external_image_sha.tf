data "external" "sha" {
    for_each   = proxmox_vm_qemu.pxe-example
    program = ["bash", "-c",<<EOT
        SSH="ssh -o StrictHostKeyChecking=no ${var.pve_ssh_user}@${var.pve_host} "
        sha=$(ssh -o StrictHostKeyChecking=no ${var.pve_ssh_user}@${var.pve_host} "sha256sum \$(/usr/sbin/pvesm path ${var.VMs[each.key].import_from})")
        sha=$(echo $sha | awk '{print $1}')
        jq -n --arg sha "$sha" '{sha:$sha}'
    EOT
    ]
}
