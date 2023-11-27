

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
  host_data_directory = "/shares/data"
}

module "volume_example" {
  source              = "../modules/persistent-volume-example"
  host_data_directory = "/shares/data"
}

module "variable-example" {
  source              = "../modules/variable-example"
  host_data_directory = "/shares/data"
}
