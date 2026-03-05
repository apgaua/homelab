resource "null_resource" "argocd_crds_manifests" {
  for_each = toset(var.argocd_crds_manifests)

  provisioner "local-exec" {
    command = "KUBECONFIG=${var.cluster.kubeconfig} kubectl apply --server-side -f \"${each.key}\""
  }
  depends_on = [null_resource.waiting, helm_release.cilium]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
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

  depends_on = [null_resource.waiting, helm_release.cilium, null_resource.argocd_crds_manifests]
}

resource "argocd_application" "applications" {
  count = length(var.applications)
  metadata {
    name      = "${var.cluster.name}-${var.applications[count.index].name}"
    namespace = "argocd"
  }

  spec {
    project = var.applications[count.index].project
    source {
      repo_url        = var.applications[count.index].repo_url
      target_revision = var.applications[count.index].revision
      path            = var.applications[count.index].path
      directory {
        recurse = var.applications[count.index].recurse
      }
    }
    destination {
      server    = var.applications[count.index].server
      namespace = var.applications[count.index].namespace
    }
    sync_policy {
      retry {
        limit = "2"
        backoff {
          duration     = "5s"
          factor       = "2"
          max_duration = "3m"
        }
      }
    }
  }
  depends_on = [helm_release.argocd]
}