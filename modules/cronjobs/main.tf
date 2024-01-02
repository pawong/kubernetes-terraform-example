resource "kubernetes_namespace" "cronjobs_namespace" {
  metadata {
    name = var.module_name
  }
}

resource "kubernetes_cron_job_v1" "cronjob" {
  metadata {
    name      = "${var.module_name}-deployment"
    namespace = kubernetes_namespace.cronjobs_namespace.metadata[0].name
    labels = {
      app = "${var.module_name}-app"
    }
  }

  spec {
    schedule = "*/5 * * * *" # The schedule in Cron format, this will run every 5 minutes

    # This job will replace an existing job if it's still running (concurrency policy "Replace")
    concurrency_policy = "Replace"

    # This is the job template
    job_template {
      metadata {}
      spec {
        template {
          metadata {
            labels = {
              app = "${var.module_name}-app"
            }
          }
          spec {
            container {
              name    = "${var.module_name}-container" # Name of the container running the job
              image   = "bash"                         # Image used for the job
              command = ["/bin/sh"]
              args    = ["-c", "date; echo Hello from the Kubernetes cluster cronjob"]
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}
