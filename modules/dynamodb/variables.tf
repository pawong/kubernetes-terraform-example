#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "dynamodb"
}

variable "domain" {
  sensitive   = false
  type        = string
  description = "Domain Name"
  default     = "jaiken.com"
}

variable "subdomain" {
  sensitive   = false
  type        = string
  description = "Subdomain Name"
  default     = "dynamodb"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
