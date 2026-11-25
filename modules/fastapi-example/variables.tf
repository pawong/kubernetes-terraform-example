#---------------------------------------------------------------------------------------------------
# Fast API
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "fastapi-example"
}

variable "domain_name" {
  sensitive   = false
  type        = string
  description = "Domain Name"
  default     = "jessica.com"
}

variable "subdomain_name" {
  sensitive   = false
  type        = string
  description = "Subdomain Name for Ingress"
  default     = "fastapi"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
}

variable "GIT_HASH" {
  sensitive   = false
  type        = string
  description = "Git commit hash"
  default     = "None"
}

variable "docker_registry" {
  description = "Docker registry address"
  type        = string
}
