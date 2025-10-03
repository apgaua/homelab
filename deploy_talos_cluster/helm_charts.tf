resource "helm_release" "main" {
  count      = length(var.helm_charts)
  name       = var.helm_charts[count.index].name
  repository = var.helm_charts[count.index].repository
  chart      = var.helm_charts[count.index].chart
  namespace  = var.helm_charts[count.index].namespace
  wait       = var.helm_charts[count.index].wait
  version    = var.helm_charts[count.index].version
  set        = var.helm_charts[count.index].set

  depends_on = [aws_eks_cluster.main]
}