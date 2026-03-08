mock_provider "proxmox" {}
mock_provider "time" {}
mock_provider "null" {}
mock_provider "external" {}

variables {
  pve_host         = "192.168.1.1"
  pve_ssh_user     = "terraform"
  pve_api_token_id = "terraform@pve!terraform"
}

# Test that a valid VM configuration with cpu.type = "host" is accepted
run "valid_cpu_type_host" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "stopped"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "host"
        }
        network = {
          id        = 0
          bridge    = "vmbr0"
          firewall  = false
          link_down = false
          model     = "virtio"
          tag       = 0
        }
      }
    }
  }
  command = plan
}

# Test that a valid VM configuration with cpu.type = "kvm64" is accepted
run "valid_cpu_type_kvm64" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "stopped"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "kvm64"
        }
        network = {}
      }
    }
  }
  command = plan
}

# Test that a valid VM configuration with cpu.type = "qemu64" is accepted
run "valid_cpu_type_qemu64" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "stopped"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "qemu64"
        }
        network = {}
      }
    }
  }
  command = plan
}

# Test that an invalid cpu.type value fails validation
run "invalid_cpu_type" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "stopped"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "invalid_type"
        }
        network = {}
      }
    }
  }
  command         = plan
  expect_failures = [var.VMs]
}

# Test that valid vm_state values are accepted
run "valid_vm_state_started" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "started"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "host"
        }
        network = {}
      }
    }
  }
  command = plan
}

# Test that vm_state = "running" is also accepted as a valid value
run "valid_vm_state_running" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "running"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "host"
        }
        network = {}
      }
    }
  }
  command = plan
}

# Test that an invalid vm_state value fails validation
run "invalid_vm_state" {
  variables {
    VMs = {
      "test-vm" = {
        vm_state       = "invalid_state"
        import_from    = "local:import/test.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "terraform"
        passwd         = "password"
        target_node    = "pve"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["test"]
        cpu = {
          cores   = 1
          sockets = 1
          type    = "host"
        }
        network = {}
      }
    }
  }
  command         = plan
  expect_failures = [var.VMs]
}

# Test that multiple VMs with different configurations are all validated
run "multiple_vms_valid" {
  variables {
    VMs = {
      "vm-1" = {
        vm_state       = "stopped"
        import_from    = "local:import/image1.qcow2"
        target_storage = "local"
        disk_format    = "qcow2"
        username       = "user1"
        passwd         = "pass1"
        target_node    = "pve1"
        ssh_key        = ["ssh-rsa AAAA"]
        tags           = ["tag1"]
        cpu = {
          cores   = 2
          sockets = 1
          type    = "host"
        }
        network = {}
      }
      "vm-2" = {
        vm_state       = "running"
        import_from    = "local:import/image2.qcow2"
        target_storage = "vms"
        disk_format    = "qcow2"
        disk_size      = "20G"
        memory         = 4096
        username       = "user2"
        passwd         = "pass2"
        target_node    = "pve2"
        ssh_key        = ["ssh-rsa BBBB"]
        tags           = ["tag2"]
        cpu = {
          cores   = 4
          sockets = 2
          type    = "kvm64"
        }
        network = {
          bridge   = "vmbr0"
          firewall = false
          tag      = 100
        }
      }
    }
  }
  command = plan
}
