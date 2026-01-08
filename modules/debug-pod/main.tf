resource "kubernetes_namespace" "debug_pod_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_deployment_v1" "debug_pod_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.debug_pod_namespace.metadata[0].name
    labels = {
      app = "${var.module_name}-app"
    }
  }

  spec {
    replicas = 1
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
          image             = "ubuntu@sha256:4a9232cc47bf99defcc8860ef6222c99773330367fcecbf21ba2edb0b810a31e"
          name              = "${var.module_name}-container"
          image_pull_policy = "Always"

          security_context {
            capabilities {
              drop = ["NET_RAW", "ALL"]
            }
            read_only_root_filesystem = true
          }

          # The actual command the container runs when it starts
          command = ["/bin/sh", "-c", "tail -f /dev/null"]

          readiness_probe {
            exec {
              command = ["/bin/sh", "-c", "cat /etc/hosts"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            failure_threshold     = 1
          }
          liveness_probe {
            exec {
              command = ["sh", "-c", "pgrep systemd || exit 0"]
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            failure_threshold     = 3
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          env {
            name  = "TEST_ENV"
            value = "this-is-the-value"
          }

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/root/"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/debug-pod/root/"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}
