################################################################################
################################# GENERAL CONFIG ###############################
################################################################################

cluster = {
  name        = "lab" # Must contain only letters, numbers, hyphen, and dot.
  description = "Default lab cluster"

  #IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  cidr           = "network/24" # CIDR of the network where the VMs will be allocated.
  resource_pool  = "k8s-lab"         # Resource pool name to be used by the nodes. To use this variable, the resource pool must have been configured manually.
  isoimage       = "metal-amd64.iso" # ISO image name uploaded to Proxmox to be used for Talos installation.
  talos_endpoint = "talosendpointIP"   # IP address to be used to access the Talos API. It should be an IP address within the CIDR range.
  vmid_prefix   = 900             # VMID prefix for all nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.
  kubeconfig    = "kubeconfigfolder/config" # Path where the kubeconfig file will be saved after the cluster is created.
}

################################################################################
############################# PROXMOX ACCESS CONFIG ############################
################################################################################

proxmox = {
  ip   = "proxmoxip" # Proxmox IP address where the resource will be deployed.
  port = "8006"           # Proxmox port, usually 8006.
}

################################################################################
################################### ##SSH CONFIG ###############################
################################################################################

ssh = {
  private_key = "/folder/.ssh/id_rsa"     # Private SSH key path to be used to connect to the VMs.
  public_key  = "/folder/.ssh/id_rsa.pub" # Public SSH key path to be injected into the VMs.
}

################################################################################
###################################### NODES ###################################
################################################################################

nodes = [
  { type = "controlplane", ip = "ip", mac_address = "BC:24:11:50:5E:51" },
  { type = "controlplane", ip = "ip", mac_address = "BC:24:11:A7:D4:68" },
  { type = "controlplane", ip = "ip", mac_address = "BC:24:11:5D:4B:DC" },
  { type = "worker", ip = "ip", mac_address = "bc:24:11:30:57:55" },
  { type = "worker", ip = "ip", mac_address = "bc:24:11:d9:ee:d1" },
  { type = "worker", ip = "ip", mac_address = "bc:24:11:59:61:62" },
  { type = "worker", ip = "ip", mac_address = "bc:24:11:16:47:cf" },
  { type = "worker", ip = "ip", mac_address = "bc:24:11:88:6b:fe" }
]

################################################################################
########################## VIRTUAL MACHINE CONFIGURATION #######################
################################################################################

hardware = {
  cpu_type = "x86-64-v2-AES"
}

worker_nodes = {
  sockets  = 1
  cores    = 2
  memory   = 4096
  #  balloon           = 1024
  disk_size = 50
}

controlplane_nodes = {
  sockets  = 1
  cores    = 2
  memory   = 3072
  #  balloon           = 1024
  disk_size = 40
}

################################################################################
#################################### HELM CHARTS ###############################
################################################################################

# Helm charts example configuration that can be used to deploy additional components
# to the cluster after its creation. This is optional and can be customized as needed.

helm_charts = [
  # Metrics Server
  # {
  #   name       = "metrics-server"
  #   repository = "https://kubernetes-sigs.github.io/metrics-server/"
  #   chart      = "metrics-server"
  #   namespace  = "kube-system"
  #   wait       = false
  #   version    = "3.12.2"
  #   set = [
  #     { name = "apiService.create", value = "true" }
  #   ]
  # },
  # # Kube State Metrics
  # {
  #   name             = "kube-state-metrics"
  #   repository       = "https://prometheus-community.github.io/helm-charts"
  #   chart            = "kube-state-metrics"
  #   namespace        = "kube-system"
  #   version         = "6.3.0"
  #   create_namespace = true
  #   set = [
  #     { name = "apiService.create", value = "true" },
  #     { name = "metricLabelsAllowlist[0]", value = "nodes=[*]" },
  #     { name = "metricAnnotationsAllowList[0]", value = "nodes=[*]" }
  #   ]
  # },
  # # NGINX Ingress Controller
  # {
  #   name             = "ingress-nginx"
  #   repository       = "https://kubernetes.github.io/ingress-nginx"
  #   chart            = "ingress-nginx"
  #   namespace        = "ingress-nginx"
  #   version          = "4.13.3"
  #   create_namespace = true
  #   set = [
  #     { name = "controller.publishService.enabled", value = "true" },
  #     { name = "controller.admissionWebhooks.enabled", value = "true" },
  #     { name = "controller.admissionWebhooks.patch.enabled", value = "true" }
  #   ]
  # }
]