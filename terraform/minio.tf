resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }
}

resource "helm_release" "minio" {
  name       = "minio"
  namespace  = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "10.1.6"
  #   values = [
  #     "${file("minio.yaml")}"
  #   ]
  #   set {
  #     name  = "service.type"
  #     value = "ClusterIP"
  #   }
  depends_on = [
    kubernetes_namespace.minio
  ]
}
