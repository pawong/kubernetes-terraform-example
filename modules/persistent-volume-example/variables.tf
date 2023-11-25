#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "kubernetes_namespace" {
  sensitive   = false
  type        = string
  description = "PV Kubernetes Namespace"
  default     = "pv-example"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
