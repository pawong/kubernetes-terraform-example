#---------------------------------------------------------------------------------------------------
# Nginx Example
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "npm"
}

variable "domain_name" {
  sensitive   = false
  type        = string
  description = "Domain Name"
  default     = "example.com"
}

variable "subdomain_name" {
  sensitive   = false
  type        = string
  description = "Subdomain Name for Ingress"
  default     = "example.com"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
