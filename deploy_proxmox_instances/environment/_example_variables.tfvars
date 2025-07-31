#This file contains the variables for the Proxmox cluster deployment. It should be placed in the environment directory and named `variables.tfvars`.
#It is recommended to create a copy of this file and rename it to `variables.tfvars` before running the Terraform script.

################################# GENERAL CONFIG #################################
cluster_name    = "lab-casa" # It is the name of the cluster that will be created.
description     = "Default lab cluster" # Description of the cluster.
proxmox_api_url = "https://<proxmoxurl>:8006/api2/json" # Proxmox API URL to deploy resources.

template     = "flatcar-production-proxmoxve-image" # Template to be used to deploy nodes.
resource_pool = "k8s-lab" # Name of the resource pool to be used. If not set, the default resource pool will be used.
# Note: The resource pool must be created in Proxmox before running the Terraform script.


################################# MASTER NODES #################################
masters = {
  count = 3 #How many master nodes?
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
  network_last_octect = 65 # Definicao de IP Master node: 192.168.XX.0
}

################################## WORKER NODES #################################
workers = {
  count = 5 # How many worker nodes?
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
  network_last_octect = 70 # Definicao de IP Worker node> 192.168.XX.0
}
