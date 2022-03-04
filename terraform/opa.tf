resource "kubernetes_config_map" "opa_policy" {
  metadata {
    name      = "minio-gateway-opa"
    namespace = "minio-gateway"
  }

  data = {
    "policy.rego" = "${file("policy.rego")}"
  }

  depends_on = [
    kubernetes_namespace.minio_gateway
  ]
}

resource "kubernetes_service" "opa_service" {
  metadata {
    name      = "opa"
    namespace = "minio-gateway"
    labels = {
      app = "opa"
    }
  }
  spec {
    selector = {
      app = "opa"
    }
    port {
      name        = "http"
      port        = 8181
      target_port = 8181
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [
    kubernetes_namespace.minio_gateway
  ]
}


resource "kubernetes_deployment" "opa" {
  metadata {
    name      = "opa"
    namespace = "minio-gateway"
    labels = {
      app = "opa"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "opa"
      }
    }

    template {
      metadata {
        name = "opa"
        labels = {
          app = "opa"
        }
      }

      spec {
        container {
          image = "openpolicyagent/opa:0.37.2"
          name  = "opa"

          args = ["run", "--ignore=.*", "--server", "/policies", "--log-level=debug", "--log-format=json-pretty"]

          env {
            name = "MINIO_ADMIN"
            value_from {
              secret_key_ref {
                key  = "access-key"
                name = "minio-gateway-secret"
              }
            }
          }

          port {
            container_port = "8181"
            name           = "http"
          }

          volume_mount {
            name       = "policies"
            mount_path = "/policies"
            read_only  = "true"
          }

        }

        volume {
          name = "policies"
          config_map {
            name = "minio-gateway-opa"
          }
        }

      }
    }
  }

  depends_on = [
    kubernetes_namespace.minio_gateway
  ]
}
