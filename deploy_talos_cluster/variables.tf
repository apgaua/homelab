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
    name          = string
    description   = string
    cidr          = string
    isoimage       = string
    resource_pool = optional(string)
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

variable "cp" {
  description = "Master nodes configuration"
  type = object({
    count               = number
    vmid_prefix         = optional(number)
    cores               = number
    memory              = number
    balloon             = optional(number)
    disk_size          =  number
    sockets             = number
    type               = string
    network_last_octect = optional(number)
  })
}

variable "workers" {
  description = "Worker nodes configuration"
  type = object({
    count               = number
    vmid_prefix         = optional(number)
    cores               = number
    memory              = number
    balloon             = optional(number)
    disk_size          =  number
    sockets             = number
    type               = string
    network_last_octect = optional(number)
  })
}

variable "ssh" {
  description = "SSH configuration"
  type = object({
    private_key = string
    public_key  = string
  })
}

variable "cp_mac_addresses" {
  description = "List of MAC addresses for the control plane nodes"
  type        = list(string)
  default     = []
}