provider "kubernetes" {
  config_path = "~/.kube/config"
}

## Data
data "external" "git" {
  program = ["sh", "-c", <<-EOSCRIPT
    echo '{"GIT_HASH": "'"$(git rev-parse --short HEAD)"'"}'
  EOSCRIPT
  ]
}

## Examples

module "postgresql" {
  source               = "../modules/postgresql"
  kubernetes_namespace = "postgresql"
  postgresql_password  = "changeme"
}

module "nginx_example" {
  source              = "../modules/nginx-example"
  domain_name         = "example.com"
  subdomain_name      = "nginx"
  host_data_directory = "/shares/data"
}

module "ingress_example" {
  source              = "../modules/ingress-example"
  domain_name         = "example.com"
  subdomain_name      = "ingress"
  host_data_directory = "/shares/data"
}

module "kotlin_example" {
  source              = "../modules/kotlin-example"
  domain_name         = "example.com"
  subdomain_name      = "kotlin"
  host_data_directory = "/shares/data"
  GIT_HASH            = data.external.git.result.GIT_HASH
}

module "express_example" {
  source              = "../modules/express-example"
  domain_name         = "example.com"
  subdomain_name      = "express"
  host_data_directory = "/shares/data"
  GIT_HASH            = data.external.git.result.GIT_HASH
}

module "fastapi_example" {
  source              = "../modules/fastapi-example"
  domain_name         = "example.com"
  subdomain_name      = "fastapi"
  host_data_directory = "/shares/data"
  GIT_HASH            = data.external.git.result.GIT_HASH
}

module "go_example" {
  source              = "../modules/go-example"
  domain_name         = "example.com"
  subdomain_name      = "go"
  host_data_directory = "/shares/data"
  GIT_HASH            = data.external.git.result.GIT_HASH
}

module "debug_pod" {
  source              = "../modules/debug-pod"
  host_data_directory = "/shares/data"
}

module "cronjobs" {
  source      = "../modules/cronjobs"
  module_name = "cronjobs"
}
