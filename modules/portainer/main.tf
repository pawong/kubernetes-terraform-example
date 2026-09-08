resource "kubernetes_namespace_v1" "portainer_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.module_name}-ingress"
    namespace = "portainer"
  }
  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "portainer"
              port {
                number = 9000
              }
            }
          }
        }
      }
    }
  }
}
