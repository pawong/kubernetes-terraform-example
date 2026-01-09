resource "kubernetes_namespace" "pv_namespace" {
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "kubernetes_persistent_volume_v1" "pv_pv" {
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
        path = "${var.host_data_directory}/pv"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "pv_pvc" {
  metadata {
    name      = "${var.kubernetes_namespace}-pvc"
    namespace = kubernetes_namespace.pv_namespace.metadata.0.name
  }
  spec {
    storage_class_name = "pstore-high"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.pv_pv.metadata.0.name
  }
}

resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    name      = "${var.kubernetes_namespace}-config-map"
    namespace = kubernetes_namespace.pv_namespace.metadata.0.name
  }
  data = {
    POSTGRES_DB       = "ps_db"
    POSTGRES_USER     = "ps_user"
    POSTGRES_PASSWORD = "handang0"
  }
}
