resource "proxmox_vm_qemu" "this" {
  count       = length(local.node_configs)
  vmid        = local.node_configs[count.index].vmid                                                           # Unique VM ID
  name        = local.node_configs[count.index].name                                                           # VM name
  description = format("Talos %s node for %s cluster", local.node_configs[count.index].type, var.cluster.name) # VM description

  agent        = 1                                                                       # QEMU Guest Agent
  skip_ipv6    = true                                                                    # Disable IPv6 in the VM
  target_node  = "pve"                                                                   # Proxmox node name where the VM will be created
  onboot       = true                                                                    # Start the VM on Proxmox boot
  vm_state     = "running"                                                               # VM state after creation
  memory       = local.node_configs[count.index].memory                                  # Memory in MB
  scsihw       = "virtio-scsi-pci"                                                       # SCSI controller type
  pool         = var.cluster.resource_pool                                               # Resource pool name
  tags         = format("%s-%s", var.cluster.name, local.node_configs[count.index].type) # Tags for the VM
  force_create = false                                                                   # Do not force creation if VMID already exists

  # CPU Configuration
  cpu {
    cores   = local.node_configs[count.index].cores   # Number of CPU cores per socket
    sockets = local.node_configs[count.index].sockets # Number of CPU sockets
    type    = var.cluster.cpu_type                    # CPU type (e.g., host, kvm64, etc.)
  }

  # Network interface and MAC address configuration
  network {
    id      = 0
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = local.node_configs[count.index].mac_addres # MAC address for the network interface
  }

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/${var.cluster.isoimage}" # ISO image for Talos installation
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = local.node_configs[count.index].disk_size # Disk size in GB
          storage = "local-lvm"
          format  = "raw"
          backup  = true
          discard = true
        }
      }

    }
  }
}

