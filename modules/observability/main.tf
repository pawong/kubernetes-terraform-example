resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "observability-ingress"
    namespace = "observability"
  }
  spec {
    ingress_class_name = "traefik"
    rule {
      host = "${var.subdomain}.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kube-prom-stack-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
