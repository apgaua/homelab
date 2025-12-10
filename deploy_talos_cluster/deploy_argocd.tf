resource "null_resource" "argocd_manifests" {
  for_each = toset(var.kubernetes_manifests)
  provisioner "local-exec" {
    command = "KUBECONFIG=${local_file.kubeconfig.filename} kubectl apply -f \"${each.key}\""
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
  values = [
    yamlencode(
      merge(
        {
          server = {
            service = { type = "LoadBalancer" }
            ha      = { enabled = var.argocd.ha, replicas = var.argocd.ha ? var.argocd.replicas : 1 }
          }
          redis      = { enabled = var.argocd.ha ? false : true }
          "redis-ha" = { enabled = var.argocd.ha }
          repoServer = { ha = { enabled = var.argocd.ha, replicas = var.argocd.ha ? var.argocd.replicas : 1 } }
          configs = {
            secret = {
              argocdServerAdminPassword      = var.argocd.password
              argocdServerAdminPasswordMtime = timestamp()
            }
            repositories = {
              gh = {
                url      = var.argocd.repo_url
                type     = "git"
                username = var.argocd.repo_user
                password = var.argocd.repo_pass
              }
            }
          }
          monitoring = {
            path     = var.argocd.monitoring_path != null ? var.argocd.monitoring_path : ""
            monorepo = var.argocd.monorepo
          }
        },
        # adiciona affinities apenas quando HA habilitado
        var.argocd.ha ? {
          server = {
            affinity = {
              podAntiAffinity = {
                preferredDuringSchedulingIgnoredDuringExecution = [
                  {
                    weight = 100
                    podAffinityTerm = {
                      labelSelector = { matchLabels = { "app.kubernetes.io/name" = "argocd-server" } }
                      topologyKey   = "kubernetes.io/hostname"
                    }
                  }
                ]
              }
            }
          }
          repoServer = {
            affinity = {
              podAntiAffinity = {
                preferredDuringSchedulingIgnoredDuringExecution = [
                  {
                    weight = 100
                    podAffinityTerm = {
                      labelSelector = { matchLabels = { "app.kubernetes.io/name" = "argocd-repo-server" } }
                      topologyKey   = "kubernetes.io/hostname"
                    }
                  }
                ]
              }
            }
          }
        } : {}
      )
    )
  ]

  depends_on = [null_resource.waiting, null_resource.argocd_manifests]
}