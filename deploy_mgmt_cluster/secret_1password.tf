resource "kubernetes_namespace_v1" "onepassword" {
  metadata {
    name = "1password"
  }
  depends_on = [null_resource.waiting]
}

resource "kubernetes_secret_v1" "op_credentials" {
  metadata {
    name      = "op-credentials"
    namespace = kubernetes_namespace_v1.onepassword.metadata[0].name
  }
  data = {
    "1password-credentials.json" = base64decode(var.onepassword_credentials_json)
    "token"                      = var.onepassword_token
  }

  type = "Opaque"

  depends_on = [null_resource.waiting]
}
