resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "oci://quay.io/cilium/charts"
  chart            = "cilium"
  namespace        = "kube-system"
  create_namespace = false
  version          = "1.19.1"

  set = [{ name = "ipam.mode", value = "kubernetes" },
    { name = "kubeProxyReplacement", value = "true" },
    { name = "securityContext.capabilities.ciliumAgent", value = "{CHOWN,DAC_OVERRIDE,FOWNER,IPC_LOCK,KILL,NET_ADMIN,NET_RAW,SETGID,SETUID,SYS_ADMIN,SYS_RESOURCE,DAC_READ_SEARCH}" },
    { name = "securityContext.capabilities.cleanCiliumState", value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" },
    { name = "cgroup.autoMount.enabled", value = "false" },
    { name = "cgroup.hostRoot", value = "/sys/fs/cgroup" },
    { name = "k8sServiceHost", value = var.cluster.talos_endpoint },
    { name = "k8sServicePort", value = "6443" }
  ]
  depends_on = [null_resource.waiting]
}