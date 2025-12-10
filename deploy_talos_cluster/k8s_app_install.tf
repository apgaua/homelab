resource "null_resource" "waiting" {
  depends_on = [local_file.kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      for i in {1..60}; do
        echo "Still waiting for kubernetes... ($i)"
        if KUBECONFIG=${local_file.kubeconfig.filename} kubectl cluster-info >/dev/null 2>&1; then
          echo "Kubernetes API is ready!"
          exit 0
        fi
        sleep 5
      done
      echo "Kubernetes did not become ready in time."
      exit 1
    EOT
  }
}

resource "helm_release" "this" {
  count            = length(var.helm_charts)
  name             = var.helm_charts[count.index].name
  repository       = var.helm_charts[count.index].repository
  chart            = var.helm_charts[count.index].chart
  namespace        = var.helm_charts[count.index].namespace
  wait             = var.helm_charts[count.index].wait
  version          = var.helm_charts[count.index].version
  create_namespace = var.helm_charts[count.index].create_namespace
  set              = var.helm_charts[count.index].set

  depends_on = [null_resource.waiting, null_resource.argocd_manifests]
}