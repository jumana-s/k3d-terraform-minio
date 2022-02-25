# Create namespace
resource "kubernetes_namespace" "minio_gateway" {
  metadata {
    name = "minio-gateway"
  }
}

# Create secret for minio creds from the other minio's secret
data "kubernetes_secret" "minio" {
  metadata {
    name      = "minio"
    namespace = "minio"
  }
}

resource "kubernetes_secret" "minio_clone" {
  metadata {
    name      = "minio"
    namespace = "minio-gateway"
  }

  data = {
    "root-password" = data.kubernetes_secret.minio.data["root-password"]
    "root-user"     = data.kubernetes_secret.minio.data["root-user"]
  }
}

# Deploy MinIO Gateway
resource "helm_release" "minio_gateway" {
  name       = "minio-gateway"
  namespace  = "minio-gateway"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "10.1.6"
  values = [
    "${file("minio-gateway.yaml")}"
  ]
  #   set {
  #     name  = "service.type"
  #     value = "ClusterIP"
  #   }
  depends_on = [
    kubernetes_namespace.minio_gateway
  ]
}

# Create secret for MinIO credentials

resource "random_string" "accesskey" {
  length  = 32
  special = false
}

resource "random_string" "secretkey" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "minio_gateway_secret" {
  metadata {
    name      = "minio-gateway-secret"
    namespace = "minio-gateway"
  }

  data = {
    "root-user"     = random_string.accesskey.result
    "root-password" = random_string.secretkey.result
    "access-key"    = random_string.accesskey.result
    "secret-key"    = random_string.secretkey.result
  }
}
