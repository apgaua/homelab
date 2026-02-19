data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.cluster.talos_endpoint]
}

data "talos_machine_configuration" "this" {
  count            = length(local.node_configs)
  talos_version    = "v1.12.4"
  cluster_name     = var.cluster.name
  machine_type     = local.node_configs[count.index].type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  cluster_endpoint = "https://${var.cluster.talos_endpoint}:6443"
}

resource "talos_machine_secrets" "this" {}

resource "talos_machine_configuration_apply" "this" {
  count                       = length(local.node_configs)
  depends_on                  = [proxmox_virtual_environment_vm.this[0]]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[count.index].machine_configuration
  node                        = local.vm_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/sda"
          image = var.iso.talos_installer_image
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
      }
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
      }
    })
  ]
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

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = var.cluster.kubeconfig
  file_permission = "0600"

}