# resource "helm_release" "ingress_nginx" {
#   depends_on = [talos_cluster_kubeconfig.this]
#   name       = "ingress-nginx"
#   repository = "oci://ghcr.io/nginx/charts/nginx-ingress"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx"
#   create_namespace = true
#   version    = "2.3.0"

#   set {
#     name  = "controller.service.type"
#     value = "NodePort"
#   }

#   set {
#     name  = "controller.service.nodePorts.http"
#     value = "30080"
#   }

#   set {
#     name  = "controller.service.nodePorts.https"
#     value = "30443"
#   }

#   set {
#     name  = "controller.publishService.enabled"
#     value = "true"
#   }

#   set {
#     name  = "controller.admissionWebhooks.enabled"
#     value = "false"
#   }

# }