terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.97.1"
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
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.15.0"
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

provider "argocd" {
  server_addr = "${var.cluster.talos_endpoint}:30080"
  username    = "admin"
  password    = var.argocd.password
  insecure    = true
}