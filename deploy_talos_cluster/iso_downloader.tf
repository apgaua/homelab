data "proxmox_file" "iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "lab"
  file_name    = proxmox_download_file.this.file_name
}

resource "proxmox_download_file" "this" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "lab"
  url          = var.iso.url
  file_name    = var.iso.file_name
}