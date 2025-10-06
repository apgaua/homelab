################################################################################
############################ BACKEND CONFIGURATION #############################
################################################################################

variable "bucket" {
  description = "S3 bucket to store the Terraform state"
  type        = string
  default     = "homelab-kuda-state"
}

################################################################################
########################## CLUSTER CONFIGURATION ###############################
################################################################################

variable "cluster" {
  description = "Cluster wide configuration"
  type = object({
    name             = string
    description      = string
    cidr             = string
    isoimage         = string
    resource_pool    = optional(string)
    talos_endpoint   = string
    vmid_prefix      = number
    kubeconfig       = string
    cpu_type         = string
    internet_gateway = string
  })
}

################################################################################
########################### PROXMOX ENDPOINT CONFIG ############################
################################################################################

variable "proxmox" {
  description = "Proxmox backend address"
  type = object({
    ip   = string
    port = number
  })
}

################################################################################
############################ WORKER NODES CONFIG ###############################
################################################################################

variable "worker" {
  description = "Hardware configuration for worker nodes"
  type = object({
    count               = number
    sockets             = number
    cores               = number
    memory              = number
    balloon             = optional(number)
    disk_size           = number
    network_last_octect = number
  })
}

################################################################################
########################## CONTROL PLANE NODES CONFIG ##########################
################################################################################

variable "controlplane" {
  description = "Hardware configuration for controlplane nodes"
  type = object({
    count               = number
    sockets             = number
    cores               = number
    memory              = number
    balloon             = optional(number)
    disk_size           = number
    network_last_octect = number
  })
}

################################################################################
########################## ADDITIONAL CONFIGURATIONS ###########################
################################################################################

variable "mac_address" {
  description = "Base MAC address for generating unique MACs for controlplane nodes"
  type        = list(string)
}

################################################################################
############################ HELM CHARTS CONFIG ################################
################################################################################

variable "helm_charts" {
  description = "values for Helm charts to be installed after the cluster is created"
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