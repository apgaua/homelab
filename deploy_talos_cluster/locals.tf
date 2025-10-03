locals {
  node_names = [
    for i, node in var.nodes : format(
      "%s-%s-%d",
      var.cluster.name,
      node.type == "worker" ? "wk" : "cp",
      sum([for j, prev_node in var.nodes : j < i && prev_node.type == node.type ? 1 : 0])
    )
  ]
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = var.cluster.kubeconfig
  file_permission = "0600"

}