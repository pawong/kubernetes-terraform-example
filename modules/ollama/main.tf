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
          # Consider pinning a specific version instead of "latest" so upgrades are deliberate
          image             = "ollama/ollama:v0.40.15"
          name              = "${var.module_name}-app"
          image_pull_policy = "IfNotPresent"

          security_context {
            read_only_root_filesystem = true
            capabilities {
              # drop = ["NET_RAW"]
              # Alternatively, dropping "ALL" is a security best practice:
              drop = ["ALL"]
            }
          }

          port {
            name           = "http"
            container_port = 11434
          }

          # Sized for qwen3-coder:30b (Q4_K_M, ~19 GB) with a 16k context on a 6-core / 32 GB node.
          # No CPU limit on purpose: CFS throttling makes token generation slow and jerky.
          resources {
            requests = {
              memory = "22Gi"
              cpu    = "4"
            }
            limits = {
              memory = "28Gi",
              cpu    = "10"
            }
          }

          env {
            name  = "OLLAMA_HOST"
            value = "0.0.0.0:11434"
          }

          env {
            name  = "OLLAMA_KEEP_ALIVE"
            value = "-1" # Keep loaded models in memory between requests
          }

          env {
            name  = "OLLAMA_CONTEXT_LENGTH"
            value = "65536" # Copilot prompts are large; the default context truncates them
          }

          env {
            name  = "OLLAMA_NUM_PARALLEL"
            value = "1" # Each parallel slot allocates its own context memory
          }

          env {
            name  = "OLLAMA_MAX_LOADED_MODELS"
            value = "1" # Switching models unloads the previous one instead of stacking them in RAM
          }

          env {
            name  = "OLLAMA_FLASH_ATTENTION"
            value = "1"
          }

          env {
            name  = "OLLAMA_KV_CACHE_TYPE"
            value = "q8_0" # requires flash attention
          }

          # Readiness Probe
          readiness_probe {
            http_get {
              path = "/"
              port = "http" # Refers to the name "http" defined in the port block
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          # Liveness Probe
          # Generous timeout: with all cores busy on inference, "/" can answer slowly,
          # and the default 1s timeout could restart the pod mid-request.
          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 20
            timeout_seconds       = 10
            failure_threshold     = 5
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
    # ingress-nginx annotations: long CPU-bound requests need more than the 60s default,
    # and unbuffered responses let tokens stream as they are generated.
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
      "nginx.ingress.kubernetes.io/proxy-buffering"    = "off"
    }
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
