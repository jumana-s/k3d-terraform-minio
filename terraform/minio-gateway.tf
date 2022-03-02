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
  depends_on = [helm_release.minio]
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
    kubernetes_namespace.minio_gateway,
    helm_release.minio
  ]
}

resource "kubernetes_service" "minio_loadbalancer" {
  metadata {
    name      = "minio"
    namespace = "minio-gateway"
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "minio-gateway"
      "app.kubernetes.io/name"     = "minio-gateway"
    }
    port {
      port        = 80
      target_port = 9001
    }

    type = "LoadBalancer"
  }
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
