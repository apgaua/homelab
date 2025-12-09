resource "null_resource" "wait_for_k8s_api" {
  depends_on = [local_file.kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      for i in {1..60}; do
        echo "Waiting for k8s API... ($i)"
        if KUBECONFIG=${local_file.kubeconfig.filename} kubectl cluster-info >/dev/null 2>&1; then
          echo "K8s API is ready!"
          exit 0
        fi
        sleep 5
      done
      echo "API did not become ready in time."
      exit 1
    EOT
  }
}

resource "helm_release" "main" {
  count            = length(local.helm_charts_with_mtime)
  name             = local.helm_charts_with_mtime[count.index].name
  repository       = local.helm_charts_with_mtime[count.index].repository
  chart            = local.helm_charts_with_mtime[count.index].chart
  namespace        = local.helm_charts_with_mtime[count.index].namespace
  wait             = local.helm_charts_with_mtime[count.index].wait
  version          = local.helm_charts_with_mtime[count.index].version
  create_namespace = local.helm_charts_with_mtime[count.index].create_namespace
  set              = local.helm_charts_with_mtime[count.index].set

  depends_on = [null_resource.wait_for_k8s_api]
}

resource "null_resource" "apply_manifests" {
  for_each = toset(var.kubernetes_manifests)
  depends_on = [null_resource.wait_for_k8s_api, helm_release.main]
  provisioner "local-exec" {
    command = "KUBECONFIG=${local_file.kubeconfig.filename} kubectl apply -f \"${each.key}\""
  }
}