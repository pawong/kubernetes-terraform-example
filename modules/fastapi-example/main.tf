resource "kubernetes_namespace" "fastapi_namespace" {
  metadata {
    name = var.module_name
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "fastapi_example_image" {
  name = "${var.module_name}-image"
  build {
    context = "${path.module}/backend"
    tag     = ["${var.module_name}-image:latest"]
    build_args = {
      GIT_HASH : var.GIT_HASH
    }
    label = {
      author : "me@example.com"
    }
  }
}

resource "kubernetes_deployment_v1" "fastapi_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.fastapi_namespace.metadata[0].name
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
          image             = "${docker_image.fastapi_example_image.name}:latest"
          name              = "${var.module_name}-container"
          image_pull_policy = "Never"

          security_context {
            run_as_non_root = true
            run_as_user     = 1001

            allow_privilege_escalation = false # Controls whether a process can gain more privileges than its parent
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]              # Drops all Linux capabilities
              add  = ["NET_BIND_SERVICE"] # Adds the specified capability
            }
          }

          resources {
            limits = {
              memory = "256Mi" # This addresses CKV_K8S_13
              cpu    = "500m"
            }
            requests = {
              memory = "128Mi" # This addresses CKV_K8S_12
              cpu    = "250m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 81
              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 81
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 1
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service_v1" "fastapi_example_service" {
  metadata {
    name      = "${var.module_name}-service"
    namespace = kubernetes_namespace.fastapi_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      port = 81
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.module_name}-ingress"
    namespace = kubernetes_namespace.fastapi_namespace.metadata[0].name
  }
  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.fastapi_example_service.metadata.0.name
              port {
                number = 81
              }
            }
          }
        }
      }
    }
  }
}
