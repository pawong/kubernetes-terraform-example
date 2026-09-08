#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "mongodb"
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
variable "mongo_username" {
  sensitive   = false
  description = "Username"
  default     = "admin"
}

variable "mongo_password" {
  sensitive   = true
  type        = string
  description = "MongoDB Password, supplied from the root secrets.auto.tfvars"
}
