data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.cluster.talos_endpoint]
}

data "talos_machine_configuration" "this" {
  count            = length(var.nodes)
  talos_version    = "v1.11.2"
  cluster_name     = var.cluster.name
  machine_type     = var.nodes[count.index].type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = "https://${var.cluster.talos_endpoint}:6443"
}

resource "talos_machine_secrets" "this" {}

resource "talos_machine_configuration_apply" "this" {
  count                       = length(var.nodes)
  depends_on                  = [proxmox_vm_qemu.this[0]]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[count.index].machine_configuration
  node                        = var.nodes[count.index].ip #proxmox_vm_qemu.this[count.index].default_ipv4_address  install_image               = "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.2"
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.cluster.talos_endpoint
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.cluster.talos_endpoint
}