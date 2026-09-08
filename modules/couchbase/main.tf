resource "kubernetes_namespace_v1" "couchbase" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_secret_v1" "couchbase" {
  metadata {
    name      = "couchbase-secret"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  data = {
    COUCHBASE_ADMINISTRATOR_USERNAME = var.couchbase_username
    COUCHBASE_ADMINISTRATOR_PASSWORD = var.couchbase_password
  }

  type = "Opaque"
}

resource "kubernetes_persistent_volume_v1" "couchbase" {
  metadata {
    name = "couchbase-pv"
  }

  spec {
    capacity = {
      storage = var.storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = "manual"

    persistent_volume_source {
      host_path {
        path = "${var.host_data_directory}/couchbase"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "couchbase" {
  metadata {
    name      = "couchbase-pvc"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.storage_request_size
      }
    }

    storage_class_name = "manual"

    volume_name = kubernetes_persistent_volume_v1.couchbase.metadata[0].name
  }
}

# Couchbase writes its own node name into the on-disk config, so the pod needs a
# stable hostname across restarts - hence a StatefulSet rather than a Deployment.
resource "kubernetes_stateful_set_v1" "couchbase" {
  metadata {
    name      = "couchbase"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name

    labels = {
      app = "couchbase"
    }
  }

  spec {
    replicas     = 1
    service_name = kubernetes_service_v1.couchbase_headless.metadata[0].name

    selector {
      match_labels = {
        app = "couchbase"
      }
    }

    template {
      metadata {
        labels = {
          app = "couchbase"
        }
      }

      spec {
        # The image runs as uid 1000, but a freshly created hostPath directory is
        # owned by root, so hand the data directory over before the server starts.
        init_container {
          name              = "couchbase-data-permissions"
          image             = var.couchbase_image
          image_pull_policy = "IfNotPresent"
          command           = ["chown", "-R", "1000:1000", "/opt/couchbase/var"]

          security_context {
            run_as_user = 0
          }

          volume_mount {
            mount_path = "/opt/couchbase/var"
            name       = "couchbase-data"
          }
        }

        container {
          name              = "couchbase"
          image             = var.couchbase_image
          image_pull_policy = "IfNotPresent"

          port {
            name           = "admin"
            container_port = 8091
          }

          port {
            name           = "views"
            container_port = 8092
          }

          port {
            name           = "query"
            container_port = 8093
          }

          port {
            name           = "search"
            container_port = 8094
          }

          port {
            name           = "data"
            container_port = 11210
          }

          env {
            name = "COUCHBASE_ADMINISTRATOR_USERNAME"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.couchbase.metadata[0].name
                key  = "COUCHBASE_ADMINISTRATOR_USERNAME"
              }
            }
          }

          env {
            name = "COUCHBASE_ADMINISTRATOR_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.couchbase.metadata[0].name
                key  = "COUCHBASE_ADMINISTRATOR_PASSWORD"
              }
            }
          }

          volume_mount {
            mount_path = "/opt/couchbase/var"
            name       = "couchbase-data"
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }

            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/ui/index.html"
              port = 8091
            }

            initial_delay_seconds = 60
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/ui/index.html"
              port = 8091
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }
        }

        restart_policy = "Always"

        volume {
          name = "couchbase-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.couchbase.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "couchbase_headless" {
  metadata {
    name      = "couchbase-headless"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  spec {
    selector = {
      app = "couchbase"
    }

    cluster_ip = "None"

    port {
      name        = "admin"
      port        = 8091
      target_port = 8091
    }

    port {
      name        = "data"
      port        = 11210
      target_port = 11210
    }
  }
}

resource "kubernetes_service_v1" "couchbase" {
  metadata {
    name      = "couchbase"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  spec {
    selector = {
      app = "couchbase"
    }

    port {
      name        = "admin"
      port        = 8091
      target_port = 8091
      node_port   = 30891
    }

    port {
      name        = "views"
      port        = 8092
      target_port = 8092
      node_port   = 30892
    }

    port {
      name        = "query"
      port        = 8093
      target_port = 8093
      node_port   = 30893
    }

    port {
      name        = "search"
      port        = 8094
      target_port = 8094
      node_port   = 30894
    }

    port {
      name        = "data"
      port        = 11210
      target_port = 11210
      node_port   = 31210
    }

    type = "NodePort"
  }
}

# A fresh Couchbase container starts unconfigured, so the cluster and the first
# bucket are created once the server answers on 8091.
resource "kubernetes_config_map_v1" "couchbase_init" {
  metadata {
    name      = "couchbase-init"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  data = {
    "cluster-init.sh" = <<-EOT
      #!/bin/bash
      set -euo pipefail

      CLUSTER="http://couchbase.${kubernetes_namespace_v1.couchbase.metadata[0].name}.svc.cluster.local:8091"

      echo "Waiting for $${CLUSTER} ..."
      until curl -fsS "$${CLUSTER}/pools" > /dev/null 2>&1; do
        sleep 5
      done

      if curl -fsS -u "$${COUCHBASE_ADMINISTRATOR_USERNAME}:$${COUCHBASE_ADMINISTRATOR_PASSWORD}" "$${CLUSTER}/pools/default" > /dev/null 2>&1; then
        echo "Cluster already initialised."
      else
        echo "Initialising cluster ..."
        couchbase-cli cluster-init \
          -c "$${CLUSTER}" \
          --cluster-username "$${COUCHBASE_ADMINISTRATOR_USERNAME}" \
          --cluster-password "$${COUCHBASE_ADMINISTRATOR_PASSWORD}" \
          --services "${var.couchbase_services}" \
          --cluster-ramsize ${var.couchbase_cluster_ram_size} \
          --cluster-index-ramsize ${var.couchbase_index_ram_size}
      fi

      if couchbase-cli bucket-list -c "$${CLUSTER}" -u "$${COUCHBASE_ADMINISTRATOR_USERNAME}" -p "$${COUCHBASE_ADMINISTRATOR_PASSWORD}" | grep -qx "${var.couchbase_bucket_name}"; then
        echo "Bucket ${var.couchbase_bucket_name} already exists."
      else
        echo "Creating bucket ${var.couchbase_bucket_name} ..."
        couchbase-cli bucket-create \
          -c "$${CLUSTER}" \
          -u "$${COUCHBASE_ADMINISTRATOR_USERNAME}" \
          -p "$${COUCHBASE_ADMINISTRATOR_PASSWORD}" \
          --bucket "${var.couchbase_bucket_name}" \
          --bucket-type couchbase \
          --bucket-ramsize ${var.couchbase_bucket_ram_size} \
          --wait
      fi
    EOT
  }
}

resource "kubernetes_job_v1" "couchbase_init" {
  metadata {
    name      = "couchbase-init"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  spec {
    backoff_limit = 6

    template {
      metadata {
        labels = {
          app = "couchbase-init"
        }
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name              = "couchbase-init"
          image             = var.couchbase_image
          image_pull_policy = "IfNotPresent"
          command           = ["bash", "/scripts/cluster-init.sh"]

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.couchbase.metadata[0].name
            }
          }

          volume_mount {
            mount_path = "/scripts"
            name       = "couchbase-init"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "couchbase-init"

          config_map {
            name         = kubernetes_config_map_v1.couchbase_init.metadata[0].name
            default_mode = "0555"
          }
        }
      }
    }
  }

  wait_for_completion = false

  depends_on = [kubernetes_stateful_set_v1.couchbase]
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.module_name}-ingress"
    namespace = kubernetes_namespace_v1.couchbase.metadata[0].name
  }

  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.couchbase.metadata[0].name
              port {
                number = 8091
              }
            }
          }
        }
      }
    }
  }
}
