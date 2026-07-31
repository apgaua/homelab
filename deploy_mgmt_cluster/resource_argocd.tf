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
    { name = "server.service.type", value = "ClusterIP" },
    # { name = "server.service.nodePortHttps", value = "30080" },
    # { name = "server.service.nodePortHttp", value = "30081" },
    { name = "configs.secret.argocdServerAdminPassword", value = bcrypt(var.argocd.password) },
    { name = "configs.secret.argocdServerAdminPasswordMtime", value = time_static.argocd_mtime.rfc3339 },
    { name = "configs.secret.argocdServerSecretKey", value = random_uuid.argocd_secret_key.result },
    { name = "controller.replicas", value = "3" },
    { name = "controller.sharding.enabled", value = "true" },
    { name = "controller.sharding.method", value = "round-robin" }
  ]
  depends_on = [null_resource.waiting, helm_release.cilium, null_resource.argocd_crds_manifests]
}

resource "local_file" "argocd_application_manifest" {
  count = length(var.applications)
  content = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.applications[count.index].name
      namespace = "argocd"
    }
    spec = {
      project = var.applications[count.index].project
      source = {
        repoURL        = var.applications[count.index].repo_url
        targetRevision = var.applications[count.index].revision
        path           = var.applications[count.index].path
        directory = {
          recurse = var.applications[count.index].recurse
        }
      }
      destination = {
        server    = var.applications[count.index].server
        namespace = var.applications[count.index].namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "ServerSideApply=true",
          "SkipDryRunOnMissingResource=true"
        ]
        retry = {
          limit = 2
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  })
  filename = "${path.module}/.terraform/argocd-app-${var.applications[count.index].name}.yaml"
}

resource "null_resource" "apply_argocd_applications" {
  count = length(var.applications)

  triggers = {
    manifest_sha = sha256(local_file.argocd_application_manifest[count.index].content)
  }

  provisioner "local-exec" {
    command = "KUBECONFIG=${var.cluster.kubeconfig} kubectl apply -f ${local_file.argocd_application_manifest[count.index].filename}"
  }

  depends_on = [helm_release.argocd, kubernetes_secret_v1.argocd_repo_secret, local_file.argocd_application_manifest, null_resource.waiting]
}

resource "kubernetes_secret_v1" "argocd_repo_secret" {
  metadata {
    name      = "apgaua-repo-secret"
    namespace = "argocd"

    # This label is critical; it tells ArgoCD to use this secret for repository credentials
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  # The Terraform Kubernetes provider automatically base64-encodes the values in the 'data' block
  data = {
    type     = "git"
    url      = var.applications[0].repo_url
    username = var.github_username
    password = var.github_token
  }

  type       = "Opaque"
  depends_on = [null_resource.waiting, helm_release.argocd]
}
