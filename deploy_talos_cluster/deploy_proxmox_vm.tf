resource "proxmox_virtual_environment_pool" "this" {
  comment = "Managed by Terraform"
  pool_id = var.cluster.resource_pool
}

resource "proxmox_virtual_environment_vm" "this" {
  count       = length(local.node_configs)
  name        = local.node_configs[count.index].name                                                           # VM name
  description = format("Talos %s node for %s cluster", local.node_configs[count.index].type, var.cluster.name) # VM description
  tags        = [format("%s-%s", var.cluster.name, local.node_configs[count.index].type)]
  node_name   = "pve"
  vm_id       = local.node_configs[count.index].vmid # Unique VM ID
  pool_id     = proxmox_virtual_environment_pool.this.pool_id

  boot_order = ["scsi0", "ide3"]

  # QUEMU Guest Agent
  agent {
    enabled = true
    trim    = true
  }

  # CPU Configuration
  cpu {
    cores   = local.node_configs[count.index].cores
    sockets = local.node_configs[count.index].sockets
    type    = var.cluster.cpu_type
  }

  # Memory Configuration
  memory {
    dedicated = local.node_configs[count.index].memory
  }

  # Disk Configuration
  disk {
    datastore_id = "local-lvm"
    size         = local.node_configs[count.index].disk_size
    file_format  = "raw"
    backup       = true
    discard      = "on"
    interface    = "scsi0"
  }

  # CDROM Configuration
  cdrom {
    file_id = data.proxmox_virtual_environment_file.iso.id
  }

  # Network Configuration
  network_device {
    model       = "virtio"
    mac_address = local.node_configs[count.index].mac_address # MAC address for the network interface
    bridge      = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }
}