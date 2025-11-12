resource "proxmox_virtual_environment_pool" "this" {
  comment = "Managed by Terraform"
  pool_id = var.cluster.resource_pool
}

resource "proxmox_virtual_environment_vm" "this" {
  count       = length(local.node_configs)
  name        = local.node_configs[count.index].name
  description = format("Talos %s node for %s cluster", local.node_configs[count.index].type, var.cluster.name)
  tags        = ["terraform", "talos", "lab"]
  node_name   = "pve"
  vm_id       = local.node_configs[count.index].vmid

  agent {
    enabled = true
    trim    = true
  }

  cpu {
    cores   = local.node_configs[count.index].cores
    sockets = local.node_configs[count.index].sockets
    type    = var.cluster.cpu_type
  }

  memory {
    dedicated = local.node_configs[count.index].memory
    floating  = local.node_configs[count.index].memory # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.node_configs[count.index].disk_size
    file_format  = "raw"
    backup       = true
    discard      = "on"
    interface    = "scsi0"
  }

  cdrom {
    file_id = data.proxmox_virtual_environment_file.iso.id
  }

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

  pool_id = proxmox_virtual_environment_pool.this.pool_id
}