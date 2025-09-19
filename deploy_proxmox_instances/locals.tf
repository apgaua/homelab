locals {
  # global configurations
  agent        = 1
  onboot       = true
  proxmox_node = "pve"
  scsihw       = "virtio-scsi-pci"

  bridge = {
    interface = "vmbr0"
    model     = "virtio"
  }

  disks = {
    main = {
      backup    = true
      format    = "raw"
      type      = "disk"
      storage   = "local-lvm"
      slot      = "scsi0"
      discard   = true
      disk_size = "105984M"
    }

    cloudinit = {
      backup = true
      # format    = "raw"
      type    = "cloudinit"
      storage = "local-lvm"
      slot    = "ide2"
    }
  }
  # serial is needed to connect via WebGUI console
  serial = {
    id   = 0
    type = "socket"
  }

  # cloud init information to be injected
  cloud_init = {
    package_upgrade = true
  }
  automatic_reboot = true
}