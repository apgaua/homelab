resource "proxmox_vm_qemu" "masters" {
  count = var.masters.count

  target_node = local.proxmox_node
  vmid        = var.masters.vmid_prefix + count.index
  name = format(
    "%s-master-%s",
    var.cluster.name,
    count.index
  )

  onboot = local.onboot
  clone  = var.cluster.template
  agent  = local.agent
  pool   = var.cluster.resource_pool

  cpu {
    cores   = var.masters.cores
    sockets = var.masters.sockets
  }

  memory  = var.masters.memory
  balloon = var.workers.balloon

  ciuser           = var.cluster.default_user
  sshkeys          = file(var.ssh.public_key)
  automatic_reboot = local.automatic_reboot
  ciupgrade        = local.cloud_init.package_upgrade
  ipconfig0 = format(
    "ip=%s/24,gw=%s",
    cidrhost(
      var.cluster.cidr,
      var.masters.network_last_octect + count.index
    ),
    cidrhost(var.cluster.cidr, 1)
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

  tags = "${var.cluster.name}-master"

  connection {
    type        = "ssh"
    user        = var.cluster.default_user
    private_key = file(var.ssh.private_key)
    host = cidrhost(
      var.cluster.cidr,
      var.masters.network_last_octect + count.index
    )
  }
  # depends_on = [ proxmox_pool.cluster ]
}