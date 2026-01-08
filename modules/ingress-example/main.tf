resource "kubernetes_namespace" "ingress_example_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_pod" "apple_pod" {
  metadata {
    name      = "apple-pod"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
    labels = {
      app = "apple"
    }
  }
  spec {
    container {
      name              = "apple-pod"
      image             = "hashicorp/http-echo@sha256:fcb75f691c8b0414d670ae570240cbf95502cc18a9ba57e982ecac589760a186"
      image_pull_policy = "Always"
      args              = ["-text=apple"]

      port {
        name           = "http"
        container_port = 5678
      }

      security_context {
        capabilities {
          drop = ["NET_RAW", "ALL"]
        }
        read_only_root_filesystem = true
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
    }
  }
}

resource "kubernetes_service_v1" "apple_service" {
  metadata {
    name      = "apple-service"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "apple"
    }
    port {
      port = 5678
    }
  }
}

resource "kubernetes_pod" "banana_pod" {
  metadata {
    name      = "banana-pod"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
    labels = {
      app = "banana"
    }
  }
  spec {
    container {
      name              = "banana-pod"
      image             = "hashicorp/http-echo@sha256:fcb75f691c8b0414d670ae570240cbf95502cc18a9ba57e982ecac589760a186"
      image_pull_policy = "Always"
      args              = ["-text=banana"]

      port {
        name           = "http"
        container_port = 5678
      }

      security_context {
        capabilities {
          drop = ["NET_RAW", "ALL"]
        }
        read_only_root_filesystem = true
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
    }
  }
}

resource "kubernetes_service_v1" "banana_service" {
  metadata {
    name      = "banana-service"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "banana"
    }
    port {
      port = 5678
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ingress-example"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
  }
  spec {
    # default_backend {
    #   service {
    #     name = kubernetes_service_v1.apple_service.metadata.0.name
    #     port {
    #       number = 5678
    #     }
    #   }
    # }
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          path = "/apple"
          backend {
            service {
              name = kubernetes_service_v1.apple_service.metadata.0.name
              port {
                number = 5678
              }
            }
          }
        }
        path {
          path = "/banana"
          backend {
            service {
              name = kubernetes_service_v1.banana_service.metadata.0.name
              port {
                number = 5678
              }
            }
          }
        }
      }
    }
  }
}
