
# Define Required Rroviders
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
}

#Connect provider 
provider "openstack" { cloud = "openstack" }

variable "name" {}
variable "image_id" {}
variable "flavor_id" {}
variable "key_pair" {}
variable "security_groups" {}
variable "network_name" {}

# Create VM k8s master
resource "openstack_compute_instance_v2" "vm1" {
  name = var.name[0]
  image_id = var.image_id
  flavor_id = var.flavor_id
  key_pair = var.key_pair
  security_groups = var.security_groups

  network {
    name = var.network_name
  }
}

## Create VM k8s worker
resource "openstack_compute_instance_v2" "vm2" {
  name = var.name[1]
  image_id = var.image_id
  flavor_id = var.flavor_id
  key_pair = var.key_pair
  security_groups = var.security_groups

  network {
    name = var.network_name
  }
}
