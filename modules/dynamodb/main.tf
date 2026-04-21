resource "kubernetes_namespace" "dynamodb_namespace" {
  metadata {
    name = var.module_name
  }
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("${path.module}/.env")) : tuple[0] => tuple[1] }
}

# Configure the AWS provider to use the local LocalStack endpoint
provider "aws" {
  # dummy credentials as they are not validated by LocalStack
  access_key = "dummy"
  secret_key = "dummy"
  region     = "us-west-2" # Can be any region

  # Explicitly set the endpoints for DynamoDB and other services
  endpoints {
    dynamodb = "http://localhost:8000"
    # Add other services if needed (e.g., s3 = "http://localhost:4566")
  }
}

resource "kubernetes_deployment_v1" "dynamodb_deployment" {
  metadata {
    name      = var.module_name
    namespace = kubernetes_namespace.dynamodb_namespace.metadata[0].name
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
          image             = "amazon/dynamodb-local:latest"
          image_pull_policy = "IfNotPresent"
          name              = "${var.module_name}-app"
          args = [
            "-jar",
            "DynamoDBLocal.jar",
            "-sharedDb",
            "-dbPath",
            "./data",
          ]
          security_context {
            # Explicitly setting user to 0 runs the container as root
            run_as_user = 0
            # Optional: Allows the root user to escalate privileges (default true)
            allow_privilege_escalation = true
          }

          port {
            name           = "${var.module_name}-port"
            container_port = 8000
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }

            requests = {
              cpu    = "0.5"
              memory = "100Mi"
            }
          }

          dynamic "env" {
            for_each = local.envs
            content {
              name  = env.key
              value = env.value
            }
          }

          # liveness_probe {
          #   http_get {
          #     path = "/"
          #     port = 8000
          #   }
          #   initial_delay_seconds = 300
          #   period_seconds        = 10
          #   timeout_seconds       = 5
          #   success_threshold     = 1
          #   failure_threshold     = 5
          # }
          # Alternative TCP Socket Probe if aws-cli is not available
          liveness_probe {
            tcp_socket {
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          volume_mount {
            name       = "${var.module_name}-pv"
            mount_path = "/home/dynamodblocal/data"
          }
        }

        restart_policy = "Always"

        volume {
          name = "${var.module_name}-pv"
          host_path {
            path = "${var.host_data_directory}/dynamodblocal/data"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "dynamodb_service" {
  metadata {
    name      = "${var.module_name}-service"
    namespace = kubernetes_namespace.dynamodb_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "${var.module_name}-app"
    }
    port {
      name        = "${var.module_name}-port"
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      node_port   = 30800
    }
    type = "NodePort"
  }
}
