resource "kubernetes_namespace" "nginx_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_deployment_v1" "nginx_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.nginx_namespace.metadata[0].name
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
          image = "nginx"
          name  = "${var.module_name}-app"

          env {
            name  = "TEST_ENV"
            value = "this-is-the-value"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 10
            period_seconds        = 10
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
    namespace = kubernetes_namespace.nginx_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "nginx-example-ingress"
    namespace = kubernetes_namespace.nginx_namespace.metadata[0].name
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
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
