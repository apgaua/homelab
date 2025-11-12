terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
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

provider "helm" {
  kubernetes = {
    config_path = var.cluster.kubeconfig
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox.ip}:${var.proxmox.port}"
  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    agent = true
  }
}