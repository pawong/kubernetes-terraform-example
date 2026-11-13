resource "kubernetes_namespace_v1" "mongodb" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_secret_v1" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace_v1.mongodb.metadata[0].name
  }

  data = {
    MONGO_INITDB_ROOT_USERNAME = var.mongo_username
    MONGO_INITDB_ROOT_PASSWORD = var.mongo_password
  }

  type = "Opaque"
}

resource "kubernetes_persistent_volume_v1" "mongodb" {
  metadata {
    name = "mongodb-pv"
  }

  spec {
    capacity = {
      storage = "20Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = "manual"

    persistent_volume_source {
      host_path {
        path = "/shares/data/mongodb"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "mongodb" {
  metadata {
    name      = "mongodb-pvc"
    namespace = kubernetes_namespace_v1.mongodb.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    storage_class_name = "manual"

    volume_name = kubernetes_persistent_volume_v1.mongodb.metadata[0].name
  }
}

resource "kubernetes_deployment_v1" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace_v1.mongodb.metadata[0].name

    labels = {
      app = "mongodb"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 3000
          fs_group        = 2000
        }

        container {
          name  = "mongodb"
          image = "mongo:8.0"

          command = ["/bin/bash", "-c"]

          args = [
            "export MONGO_INITDB_ROOT_USERNAME=\"$(cat /run/secrets/mongodb/username)\"; export MONGO_INITDB_ROOT_PASSWORD=\"$(cat /run/secrets/mongodb/password)\"; exec docker-entrypoint.sh mongod"
          ]

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }

          port {
            container_port = 27017
          }

          liveness_probe {
            exec {
              command = [
                "mongosh",
                "--quiet",
                "--eval",
                "db.adminCommand('ping')"
              ]
            }
          }

          readiness_probe {
            exec {
              command = [
                "mongosh",
                "--quiet",
                "--eval",
                "db.adminCommand('ping').ok"
              ]
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 3
          }

          volume_mount {
            name       = "mongodb-secret"
            mount_path = "/run/secrets/mongodb"
            read_only  = true
          }

          volume_mount {
            mount_path = "/data/db"
            name       = "mongodb-data"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }

            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }

        volume {
          name = "mongodb-secret"

          secret {
            secret_name = kubernetes_secret_v1.mongodb.metadata[0].name

            items {
              key  = "MONGO_INITDB_ROOT_USERNAME"
              path = "username"
            }

            items {
              key  = "MONGO_INITDB_ROOT_PASSWORD"
              path = "password"
            }

            default_mode = "0440"
          }
        }

        volume {
          name = "mongodb-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.mongodb.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace_v1.mongodb.metadata[0].name
  }

  spec {
    selector = {
      app = "mongodb"
    }

    port {
      name        = "mongodb"
      port        = 27017
      target_port = 27017
      node_port   = 32017
    }

    type = "NodePort"
  }
}
