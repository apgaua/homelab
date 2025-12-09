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

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  version          = var.argocd.version
  set = [
    { name = "server.service.type", value = "LoadBalancer" },
    { name = "configs.params.server.insecure", value = "true" },
    { name = "crds.install", value = "false" },
    { name = "configs.secret.argocdServerAdminPassword", value = var.argocd.password },
    { name = "configs.secret.argocdServerAdminPasswordMtime", value = timestamp() },
    { name = "configs.repositories.gh.url", value = var.argocd.repo_url },
    { name = "configs.repositories.gh.type", value = "git" },
    { name = "configs.repositories.gh.username", value = var.argocd.repo_user },
    { name = "configs.repositories.gh.password", value = var.argocd.repo_pass }
  ]

  depends_on = [null_resource.wait_for_k8s_api]
}

resource "helm_release" "main" {
  count            = length(var.helm_charts)
  name             = var.helm_charts[count.index].name
  repository       = var.helm_charts[count.index].repository
  chart            = var.helm_charts[count.index].chart
  namespace        = var.helm_charts[count.index].namespace
  wait             = var.helm_charts[count.index].wait
  version          = var.helm_charts[count.index].version
  create_namespace = var.helm_charts[count.index].create_namespace
  set              = var.helm_charts[count.index].set

  depends_on = [null_resource.wait_for_k8s_api]
}

resource "null_resource" "apply_manifests" {
  for_each   = toset(var.kubernetes_manifests)
  depends_on = [null_resource.wait_for_k8s_api, helm_release.main]
  provisioner "local-exec" {
    command = "KUBECONFIG=${local_file.kubeconfig.filename} kubectl apply -f \"${each.key}\""
  }
}