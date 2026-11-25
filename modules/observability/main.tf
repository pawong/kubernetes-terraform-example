resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "observability-ingress"
    namespace = "observability"
  }
  spec {
    rule {
      host = "${var.subdomain}.${var.domain}"
      http {
        path {
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
