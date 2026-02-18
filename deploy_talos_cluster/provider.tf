terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.96.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.cluster.kubeconfig
}

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