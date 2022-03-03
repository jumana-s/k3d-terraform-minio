resource "helm_release" "etcd" {
  name       = "etcd"
  namespace  = "minio-gateway"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "etcd"
  version    = "6.13.5"
  set {
    name  = "auth.rbac.create"
    value = "false"
  }
  depends_on = [
    kubernetes_namespace.minio_gateway
  ]
}
