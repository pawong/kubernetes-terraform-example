#---------------------------------------------------------------------------------------------------
# Nginx Example
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "nginx-example"
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
  default     = "subdomain"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}
