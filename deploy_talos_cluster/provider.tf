terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

provider "kubernetes" {}

# Configure the Helm provider.
provider "helm" {
  kubernetes = {
    config_path = var.cluster.kubeconfig
    }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox.ip}:${var.proxmox.port}/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "_${var.cluster.name}.log"
  pm_debug        = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}