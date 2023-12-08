terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
}

provider "openstack" { cloud = "openstack" }

module "instance_module" {
  source = "./instance"
  name = var.vm_name
  image_id = var.image_id
  flavor_id = var.flavor_id
  key_pair = var.key_pair
  security_groups = var.security_groups
  network_name = var.network_name
}