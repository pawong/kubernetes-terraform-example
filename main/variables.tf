#---------------------------------------------------------------------------------------------------
# Host Variables
#---------------------------------------------------------------------------------------------------
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
