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
        container {
          name  = "mongodb"
          image = "mongo:4.4.29"

          port {
            container_port = 27017
          }

          env {
            name = "MONGO_INITDB_ROOT_USERNAME"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mongodb.metadata[0].name
                key  = "MONGO_INITDB_ROOT_USERNAME"
              }
            }
          }

          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mongodb.metadata[0].name
                key  = "MONGO_INITDB_ROOT_PASSWORD"
              }
            }
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
