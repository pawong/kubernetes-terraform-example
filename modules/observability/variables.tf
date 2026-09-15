#---------------------------------------------------------------------------------------------------
# Observability
#---------------------------------------------------------------------------------------------------

variable "domain" {
  sensitive   = false
  type        = string
  description = "Domain Name"
  default     = "jaiken.com"
}

variable "subdomain" {
  sensitive   = false
  type        = string
  description = "Subdomains Name"
  default     = "grafz"
}
