################################# GENERAL CONFIG #################################
cluster = {
  name         = "labtalos" # Must contain only letters, numbers, hyphen, and dot.
  description  = "Default lab cluster"
#  template     = "flatcar-production-proxmoxve-image" # Template name to be used for node deployment.

  #IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  cidr = "<networkip>" # CIDR of the network where the VMs will be allocated.
  resource_pool = "k8s-lab" # Resource pool name to be used by the nodes. To use this variable, the resource pool must have been configured manually.
  isoimage      = "talos-1.11.2-metal-amd64.iso" # ISO image name uploaded to Proxmox to be used for Talos installation.
}

######################### PROXMOX ACCESS CONFIG ################################
proxmox = {
  ip   = "<proxmoxip>" # Proxmox IP address where the resource will be deployed.
  port = "8006"           # Proxmox port, usually 8006.
}

################################ SSH CONFIG ####################################
ssh = {
  private_key = "<your ssh key>"     # Private SSH key path to be used to connect to the VMs.
  public_key  = "<your ssh key>" # Public SSH key path to be injected into the VMs.
}

################################# MASTER NODES #################################
cp = {
  count       = 3   # How many master nodes?
  vmid_prefix = 900 # VMID prefix for master nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.

  # Hardware configuration.
  # Note: Disk configuration is unified in the locals file, as the value needs to be the same as the cloud-init image.
  # If you want to change the disk size, change the value in the locals file.
  cores  = 2
  memory = 2560
  #balloon = 1024
  sockets = 1
  disk_size = 50  # Disk size in GB
}

 # IMPORTANT: You should set unique MAC addresses for each control plane node. If two nodes have the same MAC address, it can cause network conflicts and instability.
 # The fixed MAC addresses will be used to ensure that each control plane node has a unique identity on the network and set IP reservations in your DHCP server.
cp_mac_addresses = [
  "AA:BB:CC:DD:EE:FF",
  "BB:CC:DD:EE:FF:GG",
  "CC:DD:EE:FF:GG:HH"
]

################################## WORKER NODES #################################
workers = {
  count       = 5   # How many worker nodes?
  vmid_prefix = 920 # VMID prefix for worker nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.

  # Hardware configuration.
  # Note: Disk configuration is unified in the locals file, as the value needs to be the same as the cloud-init image.
  # If you want to change the disk size, change the value in the locals file.
  cores  = 2
  memory = 3072
  #balloon = 1024
  sockets = 1
  disk_size = 50  # Disk size in GB
}
