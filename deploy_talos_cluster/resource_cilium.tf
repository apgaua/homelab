resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "oci://quay.io/cilium/charts"
  chart            = "cilium"
  namespace        = "kube-system"
  create_namespace = false
  version          = "1.19.1"

#   set = []
  depends_on = [null_resource.waiting]
}