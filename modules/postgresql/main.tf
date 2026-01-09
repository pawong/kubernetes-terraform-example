resource "kubernetes_namespace" "postgresql_namespace" {
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "kubernetes_persistent_volume_v1" "postgresql_pv" {
  metadata {
    name = "${var.kubernetes_namespace}-pv"
  }
  spec {
    storage_class_name               = "pstore-high"
    persistent_volume_reclaim_policy = "Retain"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/shares/data/postgresql"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgresql_pvc" {
  metadata {
    name      = "${var.kubernetes_namespace}-pvc"
    namespace = kubernetes_namespace.postgresql_namespace.metadata[0].name
  }
  spec {
    storage_class_name = "pstore-high"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_config_map_v1" "postgresql_config_map" {
  metadata {
    name      = "${var.kubernetes_namespace}-config-map"
    namespace = kubernetes_namespace.postgresql_namespace.metadata[0].name
  }
  data = {
    POSTGRES_DB       = "postgres"
    POSTGRES_USER     = "${var.postgresql_username}"
    POSTGRES_PASSWORD = "${var.postgresql_password}"
  }
}

resource "kubernetes_deployment_v1" "postgresql_deployment" {
  metadata {
    name      = "${var.kubernetes_namespace}-deployment"
    namespace = kubernetes_namespace.postgresql_namespace.metadata[0].name
    labels = {
      app = "${var.kubernetes_namespace}-app"
    }
  }

  spec {
    replicas = var.postgresql_server_count
    selector {
      match_labels = {
        app = "${var.kubernetes_namespace}-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.kubernetes_namespace}-app"
        }
      }
      spec {
        container {
          name              = "${var.kubernetes_namespace}-container"
          image             = "postgres:14"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }

          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U postgres"
              ]
            }

            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U postgres"
              ]
            }

            initial_delay_seconds = 20
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.postgresql_config_map.metadata[0].name
            }
          }

          volume_mount {
            name       = "${var.kubernetes_namespace}-pv"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.kubernetes_namespace}-pv"
          host_path {
            path = "${var.host_data_directory}/postgresql"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgresql_service" {
  metadata {
    name      = "${var.kubernetes_namespace}-service"
    namespace = kubernetes_namespace.postgresql_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.kubernetes_namespace}-app"
    }
    port {
      port = 5432
    }
  }
}
