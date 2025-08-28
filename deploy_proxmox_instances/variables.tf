variable "bucket" {
  description = "S3 bucket to store the Terraform state"
  type        = string
  default     = "homelab-kuda-state"
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "default"
}

variable "resource_pool" {
  description = "Name of the resource pool to be used"
  type        = string
  default     = ""
}

variable "proxmox_api_url" {
  description = "Proxmox url on wich resources should be deployed"
}

variable "description" {
  description = "Description of cluster"
  type        = string
  default     = "Kubernetes"
}

variable "template" {
  description = "Template to be used to deploy nodes"
  type        = string
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

variable "private_key" {
  description = "Private SSH key to connect to the VMs"
  type        = string
}