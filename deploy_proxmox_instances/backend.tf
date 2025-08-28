terraform {
  backend "s3" {
    bucket       = var.bucket
    key          = "proxmox/instances"
    use_lockfile = true
  }
}