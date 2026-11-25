provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "docker_registry" {
  description = "Local Docker registry"
  type        = string
  default     = "192.168.10.52:32000"
}

## Data/Resource
resource "terraform_data" "domain_name" {
  input = "jessica.com"
}

data "external" "git" {
  program = ["sh", "-c", <<-EOSCRIPT
    echo '{"GIT_HASH": "'"$(git rev-parse --short HEAD)"'"}'
  EOSCRIPT
  ]
}

## Examples

# module "couchbase" {
#   source              = "./modules/couchbase"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "couchbase"
#   host_data_directory = "/shares/data"
#   couchbase_password  = var.couchbase_password
# }

# module "cronjobs" {
#   source      = "./modules/cronjobs"
#   module_name = "cronjobs"
# }

# module "debug_pod" {
#   source              = "./modules/debug-pod"
#   host_data_directory = "/shares/data"
# }

# module "dynamodb" {
#   source    = "./modules/dynamodb"
#   domain    = terraform_data.domain_name.output
#   subdomain = "dynamodb"
# }

# module "express_example" {
#   source              = "./modules/express-example"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "express"
#   host_data_directory = "/shares/data"
#   GIT_HASH            = data.external.git.result.GIT_HASH
# }

module "fastapi_example" {
  source              = "./modules/fastapi-example"
  domain_name         = terraform_data.domain_name.output
  subdomain_name      = "fastapi"
  host_data_directory = "/shares/data"
  GIT_HASH            = data.external.git.result.GIT_HASH
  docker_registry     = var.docker_registry
}

# module "go_example" {
#   source              = "./modules/go-example"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "go"
#   host_data_directory = "/shares/data"
#   GIT_HASH            = data.external.git.result.GIT_HASH
# }

# module "ingress_example" {
#   source              = "./modules/ingress-example"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "ingress"
#   host_data_directory = "/shares/data"
# }

# module "kotlin_example" {
#   source              = "./modules/kotlin-example"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "kotlin"
#   host_data_directory = "/shares/data"
#   GIT_HASH            = data.external.git.result.GIT_HASH
# }

module "mongodb" {
  source         = "./modules/mongodb"
  mongo_password = var.mongodb_password
}

# module "nginx_example" {
#   source              = "./modules/nginx-example"
#   domain_name         = terraform_data.domain_name.output
#   subdomain_name      = "nginx"
#   host_data_directory = "/shares/data"
# }

module "observability" {
  source    = "./modules/observability"
  domain    = terraform_data.domain_name.output
  subdomain = "grafz"
}

module "ollama" {
  source              = "./modules/ollama"
  domain_name         = terraform_data.domain_name.output
  subdomain_name      = "ollama"
  host_data_directory = "/shares/data"
}

# module "portainer" {
#   source         = "./modules/portainer"
#  domain_name    = terraform_data.domain_name.output
#   subdomain_name = "portainer"
# }

# module "postgresql" {
#   source               = "./modules/postgresql"
#   kubernetes_namespace = "postgresql"
#   postgresql_password  = var.postgresql_password
# }
