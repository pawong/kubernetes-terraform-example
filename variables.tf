#---------------------------------------------------------------------------------------------------
# Secrets
#
# None of these have defaults on purpose, so a missing value fails the plan instead of silently
# deploying a known password. Set them in secrets.auto.tfvars, which .gitignore keeps untracked.
# Copy secrets.auto.tfvars.example to get started.
#---------------------------------------------------------------------------------------------------
variable "postgresql_password" {
  sensitive   = true
  type        = string
  description = "PostgreSQL superuser password"
}

variable "mongodb_password" {
  sensitive   = true
  type        = string
  description = "MongoDB root password"
}

variable "couchbase_password" {
  sensitive   = true
  type        = string
  description = "Couchbase administrator password (minimum 6 characters)"
}
