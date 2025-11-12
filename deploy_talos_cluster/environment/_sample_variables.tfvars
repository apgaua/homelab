################################################################################
################################# GENERAL CONFIG ###############################
################################################################################

cluster = {
  name        = "lab" # Must contain only letters, numbers, hyphen, and dot.
  description = "Default lab cluster"

  #IMPORTANT!! The value should not conflict with other devices on your network, which could cause instabilities and IP conflicts.
  cidr             = "network/24"              # CIDR of the network where the VMs will be allocated.
  resource_pool    = "k8s-lab"                 # Resource pool name to be used by the nodes. To use this variable, the resource pool must have been configured manually.
  talos_endpoint   = "talosendpointIP"         # IP address to be used to access the Talos API. It should be an IP address within the CIDR range.
  vmid_prefix      = 900                       # VMID prefix for all nodes. It is important that this value does not conflict with other VMs in Proxmox, as it must be unique.
  kubeconfig       = "kubeconfigfolder/config" # Path where the kubeconfig file will be saved after the cluster is created.
  cpu_type         = "x86-64-v2-AES"
  internet_gateway = "NetworkGWIP" # Gateway IP address for internet access.
}

################################################################################
######################### ISO IMAGE CONFIGURATION ##############################
################################################################################

iso = {
  url                   = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.11.5/metal-amd64.iso"
  file_name             = "metal-amd64.iso"
  talos_installer_image = "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.5"
}

################################################################################
############################# PROXMOX ACCESS CONFIG ############################
################################################################################

proxmox = {
  ip   = "proxmoxip" # Proxmox IP address where the resource will be deployed.
  port = "8006"      # Proxmox port, usually 8006.
}

################################################################################
########################## VIRTUAL MACHINE CONFIGURATION #######################
################################################################################

worker = {
  type                = "worker" # Type of node: worker or controlplane
  count               = 5        # Number of nodes to be created
  sockets             = 1        # Number of CPU sockets
  cores               = 2        # Number of CPU cores per socket
  memory              = 4096     # Memory in MB
  max_memory          = 4096     # Maximum Memory in MB for ballooning
  disk_size           = 50       # Disk size in GB
  network_last_octect = 90       # IP definition for Worker node: 192.168.XX.0
}

controlplane = {
  type                = "controlplane" # Type of node: worker or controlplane
  count               = 3              # Number of nodes to be created
  sockets             = 1              # Number of CPU sockets
  cores               = 2              # Number of CPU cores per socket
  memory              = 3072           # Memory in MB
  max_memory          = 3072           # Maximum Memory in MB for ballooning
  disk_size           = 40             # Disk size in GB
  network_last_octect = 60             # IP definition for Control Plane node: 192.168.XX.0
}

mac_address = [ # Base MAC addresses for generating unique MACs for controlplane nodes
  "BC:24:11:50:5E:51",
  "BC:24:11:A7:D4:68",
  "BC:24:11:5D:4B:DC"
]

################################################################################
#################################### HELM CHARTS ###############################
################################################################################

# Helm charts example configuration that can be used to deploy additional components
# to the cluster after its creation. This is optional and can be customized as needed.

helm_charts = [
  # Metrics Server
  {
    name       = "metrics-server"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    chart      = "metrics-server"
    namespace  = "kube-system"
    wait       = false
    version    = "3.12.2"
    set = [
      { name = "apiService.create", value = "true" }
    ]
  },
  # Kube State Metrics
  {
    name             = "kube-state-metrics"
    repository       = "https://prometheus-community.github.io/helm-charts"
    chart            = "kube-state-metrics"
    namespace        = "kube-system"
    version          = "6.3.0"
    create_namespace = true
    set = [
      { name = "apiService.create", value = "true" },
      { name = "metricLabelsAllowlist[0]", value = "nodes=[*]" },
      { name = "metricAnnotationsAllowList[0]", value = "nodes=[*]" }
    ]
  },
  # NGINX Ingress Controller
  {
    name             = "ingress-nginx"
    repository       = "https://kubernetes.github.io/ingress-nginx"
    chart            = "ingress-nginx"
    namespace        = "ingress-nginx"
    version          = "4.13.3"
    create_namespace = true
    set = [
      { name = "controller.publishService.enabled", value = "true" },
      { name = "controller.admissionWebhooks.enabled", value = "true" },
      { name = "controller.admissionWebhooks.patch.enabled", value = "true" }
    ]
  },
  {
    name             = "argocd"
    repository       = "https://argoproj.github.io/argo-helm"
    chart            = "argo-cd"
    namespace        = "argocd"
    create_namespace = true
    version          = "8.5.8"
    set = [
      { name = "server.service.type", value = "LoadBalancer" },
      { name = "configs.params.server.insecure", value = "true" }
    ]
  }
]