resource "random_uuid" "argocd_secret_key" {}

resource "time_static" "argocd_mtime" {
  triggers = {
    password_hash = bcrypt(var.argocd.password)
  }
}

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
    { name = "server.service.nodePortHttps", value = "30080" },
    { name = "server.service.nodePortHttp", value = "30081" },
    { name = "configs.secret.argocdServerAdminPassword", value = bcrypt(var.argocd.password) },
    { name = "configs.secret.argocdServerAdminPasswordMtime", value = time_static.argocd_mtime.rfc3339 },
    { name = "configs.secret.argocdServerSecretKey", value = random_uuid.argocd_secret_key.result },
    { name = "controller.replicas", value = "3" },
    { name = "controller.sharding.enabled", value = "true" },
    { name = "controller.sharding.method", value = "round-robin" }
  ]
  depends_on = [null_resource.waiting, helm_release.cilium, null_resource.argocd_crds_manifests]
}

resource "argocd_application" "applications" {
  count = length(var.applications)
  metadata {
    name      = var.applications[count.index].name
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
  wait       = false
  cascade    = false
  depends_on = [helm_release.argocd]
}