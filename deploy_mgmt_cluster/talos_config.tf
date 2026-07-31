data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  # Best practice: point the client configuration to actual node IPs
  endpoints = local.vm_ips
}

data "talos_machine_configuration" "this" {
  count           = length(local.node_configs)
  talos_version   = var.iso.version
  cluster_name    = var.cluster.name
  machine_type    = local.node_configs[count.index].type
  machine_secrets = talos_machine_secrets.this.machine_secrets
  # Point the cluster endpoint to the Virtual IP
  cluster_endpoint = "https://${var.cluster.vip}:6443"
}

resource "talos_machine_secrets" "this" {}

resource "talos_machine_configuration_apply" "this" {
  count                       = length(local.node_configs)
  depends_on                  = [proxmox_virtual_environment_vm.this]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[count.index].machine_configuration
  node                        = local.vm_ips[count.index]

  # Using compact() removes null values (e.g., when the VIP patch doesn't apply to workers)
  config_patches = compact([
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
    }),

    # VIP Patch: Applies ONLY if the node is a controlplane
    local.node_configs[count.index].type == "controlplane" ? yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = "ens18"
              dhcp      = true # Explicitly ensure DHCP runs so DNS/Gateway is retrieved
              vip = {
                ip = var.cluster.vip
              }
            }
          ]
        }
      }
    }) : null,

    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      auto       = "off"
      hostname   = local.node_configs[count.index].name
    })
  ])
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  # Bootstrap requires targeting a specific control plane node IP, not the VIP
  node = local.vm_ips[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  # Target a specific node IP to fetch the initial config
  node = local.vm_ips[0]
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = var.cluster.kubeconfig
  file_permission = "0600"
}

resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = var.cluster.talosconfig
  file_permission = "0600"
}
