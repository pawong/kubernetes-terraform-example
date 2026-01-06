#---------------------------------------------------------------------------------------------------
# ingress-example
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "portainer"
}

variable "domain_name" {
  sensitive   = false
  type        = string
  description = "Host URL"
  default     = "example.com"
}

variable "subdomain_name" {
  sensitive   = false
  type        = string
  description = "Subdomain Name for Ingress"
  default     = "portainer"
}
