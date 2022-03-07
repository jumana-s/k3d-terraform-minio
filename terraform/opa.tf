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

resource "kubernetes_config_map" "opa_mitmproxy_script" {
  metadata {
    name      = "opa-mitmproxy-script"
    namespace = "minio-gateway"
  }

  data = {
    "script.py" = "${file("mitmproxy-script.py")}"
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
      # Forward to nginx for logging
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
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

        container {

          name    = "mitmproxy"
          image   = "mitmproxy/mitmproxy"
          command = ["mitmdump"]
          args    = [
            "--mode", "reverse:http://0.0.0.0:8181",
            "-p", "8000",
            "-s", "/tmp/script.py"
            ]

          port {
            container_port = "8000"
            name           = "http"
          }

          volume_mount {
            name       = "mitmproxy-script"
            mount_path = "/tmp/script.py"
            sub_path   = "script.py"
            read_only  = "true"
          }
        }

        volume {
          name = "mitmproxy-script"
          config_map {
            name = "opa-mitmproxy-script"
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
