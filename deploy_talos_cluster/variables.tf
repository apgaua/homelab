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
    vmid_prefix    = number
    kubeconfig     = string
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
    type        = string
    ip          = string
    mac_address = string
  }))
}

variable "hardware" {
  description = "Base hardware configuration for the VMs"
  type = object({
    cpu_type = string
  })
}

variable "worker_nodes" {
  description = "Hardware configuration for worker nodes"
  type = object({
    sockets   = number
    cores     = number
    memory    = number
    balloon   = optional(number)
    disk_size = number
  })
}

variable "controlplane_nodes" {
  description = "Hardware configuration for control plane nodes"
  type = object({
    sockets   = number
    cores     = number
    memory    = number
    balloon   = optional(number)
    disk_size = number
  })
}

variable "ssh" {
  description = "SSH configuration"
  type = object({
    private_key = string
    public_key  = string
  })
}

variable "helm_charts" {
  type = list(object({
    name             = string
    repository       = string
    chart            = string
    namespace        = string
    create_namespace = optional(bool, false)
    wait             = optional(bool, false)
    version          = optional(string, null)
    set = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []
}