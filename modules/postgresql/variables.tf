#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "kubernetes_namespace" {
  sensitive   = false
  type        = string
  description = "Kubernetes Namespace"
  default     = "postgresql"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}

#---------------------------------------------------------------------------------------------------
# PostgreSQL
#---------------------------------------------------------------------------------------------------
variable "postgresql_server_count" {
  sensitive   = false
  type        = number
  description = "Total PostgreSQL Server"
  default     = 1
}

#---------------------------------------------------------------------------------------------------
# Authentication
#---------------------------------------------------------------------------------------------------
variable "postgresql_username" {
  sensitive   = false
  description = "Username"
  default     = "postgres"
}

variable "postgresql_password" {
  sensitive   = true
  description = "PostgreSQL Password"
}
