terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.15.3"
    }
  }
}

provider "kubernetes" {
  host                   = resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  client_certificate     = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host               = resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key         = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(resource.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate) }
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
