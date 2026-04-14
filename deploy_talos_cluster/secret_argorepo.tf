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
    username = var.github.username
    password = var.github.token
  }

  type       = "Opaque"
  depends_on = [null_resource.waiting]
}
