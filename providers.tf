terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
}

provider "proxmox" {
  # pm_log_enable = true
  # pm_log_file   = "./terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
  pm_tls_insecure     = true
  pm_api_url          = "https://${var.pve_host}:${var.pve_web_port}/api2/json"
  pm_api_token_id     = var.pve_api_token_id
  pm_api_token_secret = var.pve_api_token_secret
}
