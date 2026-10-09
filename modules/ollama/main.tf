resource "kubernetes_namespace_v1" "ollama" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_deployment_v1" "ollama_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace_v1.ollama.metadata[0].name
    labels = {
      app = "${var.module_name}-app"
    }
  }

  spec {
    replicas = 1

    # Only one pod should write to the model directory at a time
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "${var.module_name}-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.module_name}-app"
        }
      }
      spec {
        container {
          image             = "ollama/ollama:latest"
          name              = "${var.module_name}-app"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 11434
          }

          resources {
            requests = {
              memory = "2Gi"
              cpu    = "250m"
            }
            limits = {
              memory = "4Gi"
              cpu    = "500m"
            }
          }

          env {
            name  = "OLLAMA_HOST"
            value = "0.0.0.0:11434"
          }

          env {
            name  = "OLLAMA_KEEP_ALIVE"
            value = "24h" # Keep loaded models in memory between requests
          }

          # Readiness Probe
          readiness_probe {
            http_get {
              path = "/"
              port = "http" # Refers to the name "http" defined in the port block
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            failure_threshold     = 3
          }

          # Liveness Probe
          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 20
            failure_threshold     = 3
          }

          # Pull models once the server is up. Already-downloaded models are skipped quickly,
          # and a failed pull won't kill the container.
          lifecycle {
            post_start {
              exec {
                command = [
                  "/bin/sh", "-c",
                  "until ollama list >/dev/null 2>&1; do sleep 2; done; for m in ${join(" ", var.ollama_models)}; do ollama pull $m || true; done"
                ]
              }
            }
          }

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/root/.ollama" # Downloaded models are stored here
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/ollama"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "ollama_service" {
  metadata {
    name      = "${var.module_name}-service"
    namespace = kubernetes_namespace_v1.ollama.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      port        = 11434
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "ollama_ingress" {
  metadata {
    name      = "${var.module_name}-ingress"
    namespace = kubernetes_namespace_v1.ollama.metadata[0].name
  }
  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.ollama_service.metadata.0.name
              port {
                number = 11434
              }
            }
          }
        }
      }
    }
  }
}
