output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "how_many_nodes_will_be_created" {
  description = "Trouble-shooting output"
  value       = length(var.nodes)
}

output "how_many_controlplane_nodes_will_be_created" {
  description = "Trouble-shooting output"
  value       = length([for node in var.nodes : node if node.type == "controlplane"])
}

output "how_many_worker_nodes_will_be_created" {
  description = "Trouble-shooting output"
  value       = length([for node in var.nodes : node if node.type == "worker"])
}

output "talos_endpoint" {
  description = "Talos API endpoint"
  value       = var.cluster.talos_endpoint
}
