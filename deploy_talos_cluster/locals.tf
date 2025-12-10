locals {
  ################################################################################
  ################ Concatenate and merge node configurations #####################
  ################################################################################
  all_nodes = concat(
    [for i in range(var.controlplane.count) : {
      type = "controlplane"
      ip   = cidrhost(var.cluster.cidr, var.controlplane.network_last_octect + i)
    }],
    [for i in range(var.worker.count) : {
      type = "worker"
      ip   = cidrhost(var.cluster.cidr, var.worker.network_last_octect + i)
    }]
  )

  ################################################################################
  ### Extract VM IP addresses from Proxmox VMs excluding link-local addresses  ###
  ################################################################################

  cidr_prefix_len    = tonumber(split("/", var.cluster.cidr)[1])
  cidr_prefix_octets = ceil(local.cidr_prefix_len / 8)
  cidr_sample_ip     = cidrhost(var.cluster.cidr, 1)
  network_prefix     = format("%s.", join(".", slice(split(".", local.cidr_sample_ip), 0, local.cidr_prefix_octets)))

  vm_ips = [
    for vm in proxmox_virtual_environment_vm.this :
    lookup(
      { for ip in flatten(vm.ipv4_addresses) : ip => ip if startswith(ip, local.network_prefix) },
      try(keys({ for ip in flatten(vm.ipv4_addresses) : ip => ip if startswith(ip, local.network_prefix) })[0], null),
      null
    )
  ]

  ################################################################################
  # Generate a complete list of node configurations with hardware specs and MACs #
  ################################################################################
  node_configs = [
    for i, node in local.all_nodes : {
      type = node.type
      ip   = node.ip

      sockets     = node.type == "controlplane" ? var.controlplane.sockets : var.worker.sockets
      cores       = node.type == "controlplane" ? var.controlplane.cores : var.worker.cores
      memory      = node.type == "controlplane" ? var.controlplane.memory : var.worker.memory
      disk_size   = node.type == "controlplane" ? var.controlplane.disk_size : var.worker.disk_size
      mac_address = node.type == "controlplane" ? var.mac_address[sum([for j, prev_node in local.all_nodes : j < i && prev_node.type == "controlplane" ? 1 : 0])] : null

      name = format(
        "%s-%s-%d",
        var.cluster.name,
        node.type == "worker" ? "wk" : "cp",
        sum([for j, prev_node in local.all_nodes : j < i && prev_node.type == node.type ? 1 : 0])
      )
      vmid = var.cluster.vmid_prefix + i
    }
  ]
}