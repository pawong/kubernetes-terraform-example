#---------------------------------------------------------------------------------------------------
# Kubernetes
#---------------------------------------------------------------------------------------------------
variable "module_name" {
  sensitive   = false
  type        = string
  description = "Kubernetes Module Name"
  default     = "couchbase"
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
  default     = "couchbase"
}

#---------------------------------------------------------------------------------------------------
# Couchbase
#---------------------------------------------------------------------------------------------------
# Couchbase Server 8.0 aborts on startup unless the CPU is x86-64-v3 (AVX2 and friends), which the
# homelab node is not, so this stays on the newest 7.6 Community build. Bump to community-8.0.2 once
# the cluster runs on newer hardware. Enterprise builds need a licence outside dev/test.
variable "couchbase_image" {
  sensitive   = false
  type        = string
  description = "Couchbase Server image. 8.0 and later require an x86-64-v3 CPU."
  default     = "couchbase:community-7.6.2"
}

variable "couchbase_services" {
  sensitive   = false
  type        = string
  description = "Couchbase services enabled on the node (Community Edition supports data, index, query, fts)"
  default     = "data,index,query"
}

variable "couchbase_cluster_ram_size" {
  sensitive   = false
  type        = number
  description = "Data service memory quota in MiB"
  default     = 1024
}

variable "couchbase_index_ram_size" {
  sensitive   = false
  type        = number
  description = "Index service memory quota in MiB"
  default     = 512
}

variable "couchbase_bucket_name" {
  sensitive   = false
  type        = string
  description = "Bucket created after the cluster is initialised"
  default     = "default"
}

variable "couchbase_bucket_ram_size" {
  sensitive   = false
  type        = number
  description = "Bucket memory quota in MiB (must be <= couchbase_cluster_ram_size)"
  default     = 256
}

variable "storage_size" {
  sensitive   = false
  type        = string
  description = "Size of the Couchbase persistent volume"
  default     = "20Gi"
}

variable "storage_request_size" {
  sensitive   = false
  type        = string
  description = "Size requested by the Couchbase persistent volume claim"
  default     = "10Gi"
}

#---------------------------------------------------------------------------------------------------
# Authentication
#---------------------------------------------------------------------------------------------------
variable "couchbase_username" {
  sensitive   = false
  description = "Couchbase Administrator Username"
  default     = "Administrator"
}

variable "couchbase_password" {
  sensitive   = true
  type        = string
  description = "Couchbase Administrator Password (minimum 6 characters), supplied from the root secrets.auto.tfvars"
}
