provider "kubernetes" {
  config_path = "~/.kube/config"
}

## Examples

module "nginx-example" {
  source              = "../modules/nginx-example"
  host_url            = var.host_url
  host_data_directory = var.host_data_directory
}

module "ingress_example" {
  source              = "../modules/ingress-example"
  host_url            = var.host_url
  host_data_directory = var.host_data_directory
}

module "volume_example" {
  source              = "../modules/persistent-volume-example"
  host_data_directory = var.host_data_directory
}
