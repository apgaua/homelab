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
  version          = var.argocd.chart_version

  # valores simples que continuam via 'set' (opcional)
  set = [
    { name = "crds.install", value = "false" }
  ]

  # passa um values.yaml gerado dinamicamente (suporta objetos complexos como affinity)
  # values = [
  #   yamlencode({
  #     server = merge(
  #       {
  #         service = { type = "LoadBalancer" }
  #         ha      = { enabled = var.argocd.ha, replicas = var.argocd.ha ? var.argocd.replicas : 1 }
  #       },
  #       var.argocd.ha ? {
  #         affinity = {
  #           podAntiAffinity = {
  #             preferredDuringSchedulingIgnoredDuringExecution = [
  #               {
  #                 weight = 100
  #                 podAffinityTerm = {
  #                   labelSelector = { matchLabels = { "app.kubernetes.io/name" = "argocd-server" } }
  #                   topologyKey   = "kubernetes.io/hostname"
  #                 }
  #               }
  #             ]
  #           }
  #         }
  #       } : {}
  #     )

  #     redis      = { enabled = var.argocd.ha ? false : true }
  #     "redis-ha" = { enabled = var.argocd.ha }

  #     repoServer = merge(
  #       {
  #         ha = { enabled = var.argocd.ha, replicas = var.argocd.ha ? var.argocd.replicas : 1 }
  #       },
  #       var.argocd.ha ? {
  #         affinity = {
  #           podAntiAffinity = {
  #             preferredDuringSchedulingIgnoredDuringExecution = [
  #               {
  #                 weight = 100
  #                 podAffinityTerm = {
  #                   labelSelector = { matchLabels = { "app.kubernetes.io/name" = "argocd-repo-server" } }
  #                   topologyKey   = "kubernetes.io/hostname"
  #                 }
  #               }
  #             ]
  #           }
  #         }
  #       } : {}
  #     )

  #     configs = {
  #       secret = {
  #         argocdServerAdminPassword      = var.argocd.password
  #         argocdServerAdminPasswordMtime = timestamp()
  #       }
  #     }
  #   })
  # ]

  depends_on = [null_resource.waiting, null_resource.argocd_manifests]
}