resource "kubernetes_namespace" "kotlin_namespace" {
  metadata {
    name = var.module_name
  }
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "kotlin_example_image" {
  name = "${var.module_name}-image"
  build {
    context = "${path.module}/backend"
    tag     = ["${var.module_name}-image:latest"]
    build_arg = {
      name : "${var.module_name}-image"
    }
    label = {
      author : "me@nowhere.com"
    }
  }
}

resource "kubernetes_deployment_v1" "kotlin_deployment" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.kotlin_namespace.metadata[0].name
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
          image             = "${docker_image.kotlin_example_image.name}:latest"
          name              = "${var.module_name}-container"
          image_pull_policy = "Never"

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service_v1" "kotlin_example_service" {
  metadata {
    name      = "${var.module_name}-service"
    namespace = kubernetes_namespace.kotlin_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.module_name}-ingress"
    namespace = kubernetes_namespace.kotlin_namespace.metadata[0].name
  }
  spec {
    rule {
      host = "${var.subdomain_name}.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.kotlin_example_service.metadata.0.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
