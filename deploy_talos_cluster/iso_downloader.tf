data "proxmox_virtual_environment_file" "iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  file_name    = proxmox_virtual_environment_download_file.this.file_name
}

resource "proxmox_virtual_environment_download_file" "this" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = "pve"
  url                = var.iso.url
  file_name          = var.iso.file_name
  checksum           = var.iso.checksum
  checksum_algorithm = var.iso.checksum_algorithm
}