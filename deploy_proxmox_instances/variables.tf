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
    template      = string
    default_user  = string
    cidr          = string
    resource_pool = optional(string)
  })
}

variable "proxmox" {
  description = "Proxmox backend configuration"
  type = object({
    ip   = string
    port = number
  })
}

variable "masters" {
  description = "Master nodes configuration"
  type = object({
    count               = number
    vmid_prefix         = optional(number)
    cores               = number
    memory              = number
    balloon             = optional(number)
    sockets             = number
    network_last_octect = number
  })
}

variable "workers" {
  description = "Worker nodes configuration"
  type = object({
    count               = number
    vmid_prefix         = number
    cores               = number
    memory              = number
    sockets             = number
    balloon             = optional(number)
    network_last_octect = number
  })
}

variable "ssh" {
  description = "SSH configuration"
  type = object({
    private_key = string
    public_key  = string
  })
}