#Backend configuration
variable "bucket" {
  description = "S3 bucket to store the Terraform state"
  type        = string
  default     = "homelab-kuda-state"
}

#Cluster configuration
variable "cluster" {
  description = "Configurations for the cluster"
  type = object({
    name           = string
    description    = string
    cidr           = string
    isoimage       = string
    resource_pool  = optional(string)
    talos_endpoint = string
  })
}

variable "proxmox" {
  description = "Proxmox backend configuration"
  type = object({
    ip   = string
    port = number
  })
}

variable "nodes" {
  description = "List of nodes to be created"
  type = list(object({
    vmid        = number
    type        = string
    ip          = string
    mac_address = string
  }))
}

variable "hardware" {
  description = "Hardware configuration for the nodes"
  type = object({
    cpu_type         = string
    sockets           = number
    cores             = number
    memory            = number
    balloon           = optional(number)
    disk_size         = number
  })
}

variable "ssh" {
  description = "SSH configuration"
  type = object({
    private_key = string
    public_key  = string
  })
}