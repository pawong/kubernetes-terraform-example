#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Debug Pod Module"
  default     = "debug-pod"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
