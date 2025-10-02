terraform {
  backend "s3" {
    bucket       = var.bucket
    key          = "proxmox/talosinstances"
    use_lockfile = true
  }
}