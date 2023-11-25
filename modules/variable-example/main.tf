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
          image = "ubuntu"
          name  = "${var.module_name}-app"

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/home"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/ubuntu/home"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}
