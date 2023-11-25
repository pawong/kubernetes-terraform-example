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
      name  = "apple-pod"
      image = "hashicorp/http-echo"
      args  = ["-text=apple"]
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
      name  = "banana-pod"
      image = "hashicorp/http-echo"
      args  = ["-text=banana"]
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
    name      = "example-ingress"
    namespace = kubernetes_namespace.ingress_example_namespace.metadata.0.name
  }
  spec {
    rule {
      host = "apple.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.apple_service.metadata.0.name
              port {
                number = 5678
              }
            }
          }
        }
      }
    }
    rule {
      host = "banana.${var.domain_name}"
      http {
        path {
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
