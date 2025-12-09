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

resource "null_resource" "apply_manifests" {
  for_each = toset(var.kubernetes_manifests)
  provisioner "local-exec" {
    command = "KUBECONFIG=${local_file.kubeconfig.filename} kubectl apply -f \"${each.key}\""
  }
  depends_on = [null_resource.wait_for_k8s_api, helm_release.this]
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

  depends_on = [null_resource.wait_for_k8s_api]
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

  depends_on = [null_resource.wait_for_k8s_api]
}