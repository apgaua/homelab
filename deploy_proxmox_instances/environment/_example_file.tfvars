################################# GENERAL CONFIG #################################

cluster_name    = "lab-casa" # Deve conter apenas letras, numeros, hifen e ponto.
description     = "Default lab cluster"
proxmox_api_url = "https://<proxmoxurl>:8006/api2/json" # URL do proxmox onde o recurso será implementado.

# Nome do template a ser usado para deploy dos nodes.
template     = "flatcar-production-proxmoxve-image"

# Nome do resourcepool a ser utilizado pelos nodes.
# Para usar esta variavel, o resource pool deve ter sido configurado manualmente.
resource_pool = "k8s-lab"

################################# MASTER NODES #################################

masters = {
  # Quantos nodes?
  count = 3

  # IMPORTANTE, valor nao pode concorrer com
  #  outras VMs no Proxmox, o valor deve ser unico.
  vmid_prefix = 900

  # Configuracoes de hardware. 
  # Nota: Configuracao de disco esta unificada no arquivo locals,
  # pois o valor precisa ser o mesmo da imagem cloud-init.
  cores  = 2
  memory = 2048
  #balloon = 1024
  sockets = 2

  # Configuracoes de rede. 
  # IMPORTANTE!! Valor nao deve concorrer com outros disposivos
  # em sua rede, podendo causar instabilidades e conflitos de IP.
  network_last_octect = 65 # Definicao de IP Master node: 192.168.XX.0
}

################################## WORKER NODES #################################

workers = {
  # Quantos worker nodes?
  count = 5

  # IMPORTANTE, valor nao pode concorrer com
  #  outras VMs no Proxmox, o valor deve ser unico.
  vmid_prefix = 920

  # Configuracoes de hardware. 
  # Nota: Configuracao de disco esta unificada no arquivo locals,
  # pois o valor precisa ser o mesmo da imagem cloud-init.
  cores  = 2
  memory = 3072
  #balloon = 1024
  sockets = 2

  # Configuracoes de rede. 
  # IMPORTANTE!! Valor nao deve concorrer com outros disposivos 
  # em sua rede, podendo causar instabilidades e conflitos de IP.
  network_last_octect = 70 # Definicao de IP Worker node> 192.168.XX.0
}
