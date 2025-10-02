resource "proxmox_vm_qemu" "workers"{
  count = var.workers.count
  vmid        = var.workers.vmid_prefix + count.index
  name = format(
    "%s-workers-%s",
    var.cluster.name,
    count.index
  )
  target_node = "pve"
  onboot = true
  vm_state = "running"
  memory = var.workers.memory
  balloon = var.workers.balloon
  scsihw = "virtio-scsi-pci"
  pool  = var.cluster.resource_pool
  tags = "${var.cluster.name}-worker"
  force_create = false
# CPU Configuration
  cpu {
    cores   = var.workers.cores
    sockets = var.workers.sockets
  }

# Network interface and MAC address configuration
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

# 
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
                    size    = var.workers.disk_size
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

