terraform {
  backend "s3" {
    bucket       = var.bucket
    key          = "proxmox/mgmt_cluster"
    use_lockfile = true
  }
}
