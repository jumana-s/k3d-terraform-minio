resource "kubernetes_config_map" "opa_policy" {
  metadata {
    name      = "minio-gateway-opa"
    namespace = "minio-gateway"
  }

  data = {
    "config" = "${file("policy.rego")}"
  }
}

resource "kubernetes_service" "opa_service" {
  metadata {
    name      = "opa"
    namespace = "minio-gateway"
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "opa"
    }
    port {
      port        = 8181
      target_port = 8181
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "opa" {
  metadata {
    name      = "opa"
    namespace = "minio-gateway"
    labels = {
      "app.kubernetes.io/name" = "opa"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "opa"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "opa"
        }
      }

      spec {
        container {
          image             = "openpolicyagent/opa:0.37.2"
          name              = "opa"
          image_pull_policy = "Always"

          args = ["run", "--ignore=.*", "--server", "/policies"]

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
            protocol       = "TCP"
          }

          liveness_probe {
            http_get {
              path   = "/"
              port   = 8181
              scheme = "HTTP"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "500Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "250Mi"
            }
          }

          volume_mount {
            name              = "policies"
            mount_path        = "/policies"
            mount_propagation = "None"
            read_only         = "true"
          }

        }

        volume {
          name = "policies"
          config_map {
            default_mode = "0420"
            name         = "minio-gateway-opa"
          }
        }

      }
    }
  }
}
