resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
    cluster_name = var.cluster.name
    client_configuration = talos_machine_secrets.this.client_configuration
    endpoints = [var.cluster.talos_endpoint]
    }

data "talos_machine_configuration" "controlplane" {
  talos_version = "v1.11.2"
  cluster_name = var.cluster.name
  machine_type = "controlplane"
  machine_secrets = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = "https://${var.cluster.talos_endpoint}:6443"
}

data "talos_machine_configuration" "workers" {
  talos_version = "v1.11.2"
  cluster_name = var.cluster.name
  machine_type = "worker"
  machine_secrets = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = "https://${var.cluster.talos_endpoint}:6443"
  }

resource "talos_machine_configuration_apply" "controlplane" {
  count = var.cp.count
  depends_on = [proxmox_vm_qemu.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node = proxmox_vm_qemu.controlplane[count.index].default_ipv4_address
  }

resource "talos_machine_configuration_apply" "workers" {
  count = var.workers.count
  depends_on = [proxmox_vm_qemu.workers,talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node = proxmox_vm_qemu.workers[count.index].default_ipv4_address
  }

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node = var.cluster.talos_endpoint
  }

  resource "talos_cluster_kubeconfig" "this" {
    depends_on = [ talos_machine_bootstrap.this]
    client_configuration = talos_machine_secrets.this.client_configuration
    node = var.cluster.talos_endpoint
  }

  output "talosconfig" {
    value = data.talos_client_configuration.this.talos_config
    sensitive = true
  }

output "kubeconfig" {
    value = talos_cluster_kubeconfig.this.kubeconfig_raw
    sensitive = true
  }