resource "proxmox_vm_qemu" "this" {
  count = length(var.nodes)
  vmid  = var.nodes[count.index].vmid
  name = format(
    "%s-%s-%s",
    var.cluster.name,
    var.nodes[count.index].type,
    count.index
  )

  agent        = 1                                                              # QEMU Guest Agent
  skip_ipv6    = true                                                           # Disable IPv6 in the VM
  target_node  = "pve"                                                          # Proxmox node name where the VM will be created
  onboot       = true                                                           # Start the VM on Proxmox boot
  vm_state     = "running"                                                      # VM state after creation
  memory       = var.hardware.memory                                            # Memory in MB
  balloon      = var.hardware.balloon                                           # Balloon memory in MB
  scsihw       = "virtio-scsi-pci"                                              # SCSI controller type
  pool         = var.cluster.resource_pool                                      # Resource pool name
  tags         = format("%s-%s", var.cluster.name, var.nodes[count.index].type) # Tags for the VM
  force_create = false                                                          # Do not force creation if VMID already exists

  # CPU Configuration
  cpu {
    cores   = var.hardware.cores
    sockets = var.hardware.sockets
    type    = var.hardware.cpu_type
  }

  # Network interface and MAC address configuration
  network {
    id      = 0
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = var.nodes[count.index].mac_address
  }

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/${var.cluster.isoimage}"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = var.hardware.disk_size
          storage = "local-lvm"
          format  = "raw"
          backup  = true
          discard = true
        }
      }

    }
  }

  serial {
    id   = 0
    type = "socket"
  }
}

