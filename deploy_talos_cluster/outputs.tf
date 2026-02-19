output "talosconfig" {
  description = "value of talosconfig to be used with talosctl"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "value of kubeconfig to be used with kubectl"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "kubernetes_endpoint" {
  description = "Kubernetes API endpoint"
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
}

output "talos_endpoint" {
  description = "Talos API endpoint"
  value       = var.cluster.talos_endpoint
}

output "how_many_nodes_will_be_created" {
  description = "Troubleshooting output"
  value       = length(local.node_configs)
}

output "how_many_controlplane_nodes_will_be_created" {
  description = "Troubleshooting output"
  value       = var.controlplane.count
}

output "how_many_worker_nodes_will_be_created" {
  description = "Troubleshooting output"
  value       = var.worker.count
}

output "installed_helm_charts" {
  description = "List of installed Helm charts with their versions"
  value       = { for chart in var.helm_charts : chart.name => chart.version }
}

# output "kubernetes_manifests_applied" {
#   description = "List of Kubernetes manifests that will be applied after cluster creation"
#   value       = var.kubernetes_manifests[*]
# }

output "node_names" {
  description = "List of node names that will be created"
  value       = local.node_configs[*].name
}

output "kubeconfig_file_path" {
  description = "Path where kubeconfig file is saved"
  value       = var.cluster.kubeconfig
}