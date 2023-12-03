resource "kubernetes_namespace" "debug_pod_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_deployment_v1" "debug_pod_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.debug_pod_namespace.metadata[0].name
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
          image             = "ubuntu"
          name              = "${var.module_name}-container"
          image_pull_policy = "IfNotPresent"
          command           = ["sleep", "604800"]

          env {
            name  = "TEST_ENV"
            value = "this-is-the-value"
          }

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/root/"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/debug-pod/root/"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}
