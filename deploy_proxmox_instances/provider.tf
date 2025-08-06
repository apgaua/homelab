terraform {
  required_providers {
    proxmox = {
      source = "local/apgaua/Documents/Codes/terraform-provider-proxmox"
      version = "0.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "_${var.cluster_name}.log"
  pm_debug        = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}