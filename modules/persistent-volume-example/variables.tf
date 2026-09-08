#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "kubernetes_namespace_v1" {
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

#---------------------------------------------------------------------------------------------------
# Authentication
#---------------------------------------------------------------------------------------------------
variable "postgresql_password" {
  sensitive   = true
  type        = string
  description = "PostgreSQL Password, supplied from the root secrets.auto.tfvars"
}
