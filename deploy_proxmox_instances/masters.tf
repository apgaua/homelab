resource "proxmox_vm_qemu" "masters" {
  count = var.masters.count

  target_node = local.proxmox_node
  vmid        = var.masters.vmid_prefix + count.index
  name = format(
    "%s-master-%s",
    var.cluster_name,
    count.index
  )

  onboot  = local.onboot
  clone   = var.template
  agent   = local.agent
  pool    = var.resource_pool
  cores   = var.masters.cores
  sockets = var.masters.sockets
  memory  = var.masters.memory
  balloon = var.workers.balloon

  ciuser           = local.cloud_init.user
  sshkeys          = local.cloud_init.ssh_public_key
  automatic_reboot = local.automatic_reboot
  ciupgrade        = local.cloud_init.package_upgrade
  ipconfig0 = format(
    "ip=%s/24,gw=%s",
    cidrhost(
      local.cidr,
      var.masters.network_last_octect + count.index
    ),
    cidrhost(local.cidr, 1)
  )

  network {
    id     = 0
    bridge = local.bridge.interface
    model  = local.bridge.model
  }

  scsihw = local.scsihw

  serial {
    id   = local.serial.id
    type = local.serial.type
  }

  disk {
    backup = local.disks.cloudinit.backup
    # format  = local.disks.cloudinit.format
    type    = local.disks.cloudinit.type
    storage = local.disks.cloudinit.storage
    slot    = local.disks.cloudinit.slot
  }

  disk {
    backup  = local.disks.main.backup
    format  = local.disks.main.format
    type    = local.disks.main.type
    storage = local.disks.main.storage
    size    = local.disks.main.disk_size
    slot    = local.disks.main.slot
    discard = local.disks.main.discard
  }

  tags = "${var.cluster_name}-master"

  connection {
    type        = "ssh"
    user        = local.cloud_init.user
    private_key = file("/Users/apgaua/.ssh/id_rsa")
    host = cidrhost(
      local.cidr,
      var.masters.network_last_octect + count.index
    )
  }
  # depends_on = [ proxmox_pool.cluster ]
}