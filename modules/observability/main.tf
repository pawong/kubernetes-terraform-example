resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "observability-ingress"
    namespace = "observability"
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt"
    }
  }
  spec {
    tls {
      hosts       = ["${var.subdomain}.${var.domain}"]
      secret_name = "${var.subdomain}.${var.domain}-tls"
    }
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
