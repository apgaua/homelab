#This file contains the variables for the Proxmox cluster deployment. It should be placed in the environment directory and named `variables.tfvars`.
#It is recommended to create a copy of this file and rename it to `variables.tfvars` before running the Terraform script.

################################# GENERAL CONFIG ###############################
cluster = {
  name         = "lab-casa" # Must contain only letters, numbers, hyphen, and dot.
  description  = "Default lab cluster"
  template     = "flatcar-production-proxmoxve-image" # Template name to be used for node deployment.
  default_user = "core"                               # Default user of the template image.

  #IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  cidr = "192.168.XXX.0/24" # CIDR of the network where the VMs will be allocated.

  resource_pool = ""   # Resource pool name to be used by the nodes. To use this variable, the resource pool must have been configured manually.
}

######################### PROXMOX ACCESS CONFIG ################################
proxmox = {
  ip   = "192.168.XXX.XXXX" # Proxmox IP address where the resource will be deployed.
  port = "8006"             # Proxmox port, usually 8006.
}

################################ SSH CONFIG ####################################
ssh = {
  private_key = "<caminho private key>" # Private SSH key path to be used to connect to the VMs.
  public_key  = "<caminho public key>"  # Public SSH key path to be injected into the VMs.
}

################################# MASTER NODES #################################
masters = {
  count       = 3   #How many master nodes?
  vmid_prefix = 900 # VMID prefix for master nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.

  # Hardware configuration.
  # Note: Disk configuration is unified in the locals file, as the value needs to be the same as the cloud-init image.
  # If you want to change the disk size, change the value in the locals file.
  cores  = 2
  memory = 2048
  #balloon = 1024
  sockets = 2

  # Network configuration.
  # IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  network_last_octect = 65 # IP definition for Master node: 192.168.XX.0
}

################################## WORKER NODES ################################
workers = {
  count       = 5   # How many worker nodes?
  vmid_prefix = 920 # VMID prefix for worker nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.

  # Hardware configuration.
  # Note: Disk configuration is unified in the locals file, as the value needs to be the same as the cloud-init image.
  # If you want to change the disk size, change the value in the locals file.
  cores  = 2
  memory = 3072
  #balloon = 1024
  sockets = 2

  # Network configuration.
  # IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  network_last_octect = 70 # IP definition for Worker node: 192.168.XX.0
}
