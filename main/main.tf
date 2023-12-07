

provider "kubernetes" {
  config_path = "~/.kube/config"
}

## Examples

module "nginx-example" {
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

module "fastapi_example" {
  source              = "../modules/fastapi-example"
  domain_name         = "example.com"
  subdomain_name      = "fastapi"
  host_data_directory = "/shares/data"
}

module "debug_pod" {
  source              = "../modules/debug-pod"
  host_data_directory = "/shares/data"
}
