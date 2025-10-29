variable "pve_host" {
  type = string
}

variable "pve_web_port" {
  type    = string
  default = "8006"
}

variable "pve_ssh_user" {
  type = string
}

variable "pve_api_token_id" {
  type = string
}

variable "pve_api_token_secret" {
  default = "NULL"
  type    = string
}

variable "VMs" {
  type = map(object({
    vm_state       = optional(string, "stopped")
    import_from    = string
    target_storage = string
    disk_format    = string
    disk_size      = optional(string, "10G")
    memory         = optional(number, 2)
    #disk            = number
    username     = string
    passwd       = string
    target_node  = string
    ssh_key      = list(string)
    tags         = list(string)
    force_import = optional(bool, false) # Forcing import disk image
    cpu = object({
      cores   = number
      sockets = number
      type    = string
    })
    network = object({
      id        = optional(number, 2)
      bridge    = optional(string, "vrbr0")
      firewall  = optional(bool, true)
      link_down = optional(bool, false)
      model     = optional(string, "virtio")
      tag       = optional(number, 0)
    })
  }))
  validation {
    condition = alltrue([
      for _, vm in var.VMs :
      contains(["host", "kvm64", "qemu64"], lower(vm.cpu.type))
    ])
    error_message = "cpu_type must be one of: host, kvm64, qemu64"
  }
  validation {
    condition = alltrue([
      for _, vm in var.VMs :
      contains(["started", "stopped", "running"], lower(vm.vm_state))
    ])
    error_message = "vm_state must be one of: started, stoped, running"
  }

  default = {
    "default-vm" = {
      vm_state       = "stopped"
      import_from    = "local:import/cloudimage.qcow2"
      target_storage = "local"
      disk_format    = "qcow2"
      disk_size      = "10G"
      memory         = 2
      username       = "terraform"
      passwd         = "password"
      target_node    = "pve"
      ssh_key        = ["ssh_key1", "ssh_key.."]
      tags           = [""]
      force_import   = false
      cpu = {
        cores   = 1
        sockets = 1
        type    = "host"
      }
      network = {
        id           = 0
        bridge       = "vrbr0"
        firewall     = true
        link_down    = false
        model        = "virtio"
        tag          = 0
        force_import = false
      }
    }
  }
}
