terraform {
  backend "s3" {
    bucket       = var.bucket
    key          = "proxmox/talos_instances"
    use_lockfile = true
  }
}