resource "proxmox_vm_qemu" "controlplane"{
  count = var.cp.count
  vmid        = var.cp.vmid_prefix + count.index
  name = format(
    "%s-controlplane-%s",
    var.cluster.name,
    count.index
  )
  agent = 1
  skip_ipv6 = true
  target_node = "pve"
  onboot = true
  vm_state = "running"
  memory = var.cp.memory
  balloon = var.cp.balloon
  scsihw = "virtio-scsi-pci"
  pool  = var.cluster.resource_pool
  tags = "${var.cluster.name}-controlplane"
  force_create = false
# CPU Configuration
  cpu {
    cores   = var.cp.cores
    sockets = var.cp.sockets
  }

# Network interface and MAC address configuration
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
    macaddr = var.cp_mac_addresses[count.index]
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
                    size    = var.cp.disk_size
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

  connection {
    type        = "ssh"
    user        = var.cluster.default_user
    private_key = file(var.ssh.private_key)
    host = cidrhost(
      var.cluster.cidr,
      var.masters.network_last_octect + count.index
    )
  }
}

