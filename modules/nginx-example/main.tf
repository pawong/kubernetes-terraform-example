resource "kubernetes_namespace_v1" "nginx_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_deployment_v1" "nginx_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace_v1.nginx_namespace.metadata[0].name
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
          image             = "nginxinc/ingress-demo@sha256:5c700ccd073ae0f9bd8d6ed37bfadbabcfbe2a0cbd10564c6a94601233c3ed2a"
          name              = "${var.module_name}-app"
          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]              # Drops all Linux capabilities
              add  = ["NET_BIND_SERVICE"] # Adds the specified capability
            }
            read_only_root_filesystem = false
          }

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "125m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }

          env {
            name  = "TEST_ENV"
            value = "this-is-the-value"
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
            initial_delay_seconds = 15 # Give the app a bit more time to start before the first liveness check
            period_seconds        = 20
            failure_threshold     = 3
          }

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/usr/share/nginx/html"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/nginx/html"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx_example_service" {
  metadata {
    name      = "${var.module_name}-service"
    namespace = kubernetes_namespace_v1.nginx_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "nginx-example-ingress"
    namespace = kubernetes_namespace_v1.nginx_namespace.metadata[0].name
  }
  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.nginx_example_service.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
