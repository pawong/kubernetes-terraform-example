#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "ollama"
}

variable "host_data_directory" {
  sensitive   = false
  type        = string
  description = "Host Data Directory"
  default     = "/shares/data"
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
  default     = "ollama"
}


variable "ollama_models" {
  sensitive   = false
  type        = list(string)
  description = "Ollama models to pull on startup"
  default     = ["llama3.2"]
}
