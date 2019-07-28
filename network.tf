# Main region
# Here we are installing our "stub" network and actuall aplication VPC
variable "main_region" {}

module "stub-network" {
  network_name = "Stub (hop) network"
  source       = "modules/stub-network"
  region       = "${var.main_region}"
  cidr_block   = "10.1.0.0/16"
}

module "app-network" {
  network_name = "Application network"
  source       = "modules/app-network"
  region       = "${var.main_region}"
  cidr_block   = "10.10.0.0/16"
}
