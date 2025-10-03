resource "proxmox_vm_qemu" "this" {
  count = length(var.nodes)
  vmid  = var.cluster.vmid_prefix + count.index # Unique VM ID
  name = local.node_names[count.index]                       # VM name
  description = format("Talos %s node for %s cluster", var.nodes[count.index].type, var.cluster.name) # VM description

  agent        = 1                                                              # QEMU Guest Agent
  skip_ipv6    = true                                                           # Disable IPv6 in the VM
  target_node  = "pve"                                                          # Proxmox node name where the VM will be created
  onboot       = true                                                           # Start the VM on Proxmox boot
  vm_state     = "running"                                                      # VM state after creation
  memory       = var.nodes[count.index].type == "worker" ? var.worker_nodes.memory : var.controlplane_nodes.memory # Memory in MB
  balloon      = var.nodes[count.index].type == "worker" ? var.worker_nodes.balloon : var.controlplane_nodes.balloon # Balloon memory in MB
  scsihw       = "virtio-scsi-pci"                                              # SCSI controller type
  pool         = var.cluster.resource_pool                                      # Resource pool name
  tags         = format("%s-%s", var.cluster.name, var.nodes[count.index].type) # Tags for the VM
  force_create = false                                                          # Do not force creation if VMID already exists

  # CPU Configuration
  cpu {
    cores   = var.nodes[count.index].type == "worker" ? var.worker_nodes.cores : var.controlplane_nodes.cores
    sockets = var.nodes[count.index].type == "worker" ? var.worker_nodes.sockets : var.controlplane_nodes.sockets
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
          size    = var.nodes[count.index].type == "worker" ? var.worker_nodes.disk_size : var.controlplane_nodes.disk_size
          storage = "local-lvm"
          format  = "raw"
          backup  = true
          discard = true
        }
      }

    }
  }
}

