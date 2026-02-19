resource "null_resource" "argocd_manifests" {
  for_each = toset(var.kubernetes_manifests)

  provisioner "local-exec" {
    command = "KUBECONFIG=${var.cluster.kubeconfig} kubectl apply --server-side -f \"${each.key}\""
  }
  depends_on = [null_resource.waiting]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  atomic           = true
  timeout          = 900
  version          = var.argocd.chart_version

  set = [
    { name = "crds.install", value = "false" },
    { name = "server.service.type", value = "NodePort" },
    { name = "server.service.nodePort", value = "30080" },
    { name = "configs.secret.argocdServerAdminPassword", value = bcrypt(var.argocd.password) },
    { name = "configs.secret.argocdServerAdminPasswordMtime", value = timestamp() },
    { name = "configs.secret.argocdServerSecretKey", value = uuid() }
  ]
  depends_on = [null_resource.waiting, null_resource.argocd_manifests, helm_release.cilium]
}