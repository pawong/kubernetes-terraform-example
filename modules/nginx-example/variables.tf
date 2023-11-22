#---------------------------------------------------------------------------------------------------
# Nginx Example
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "npm"
}

variable "host_url" {
  sensitive   = false
  type        = string
  description = "Host URL"
  default     = "example.com"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
