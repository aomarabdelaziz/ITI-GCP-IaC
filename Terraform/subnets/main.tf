/*
  This Terraform code defines a resource of type google_compute_subnetwork that creates multiple subnets in a Google Cloud Platform (GCP) Virtual Private Cloud (VPC). 
*/

resource "google_compute_subnetwork" "gke-subnet" {
  for_each                 = var.subnets // allows for multiple subnets to be created, with each subnet's attributes specified in the var.subnets variable.
  name                     = each.value["name"]  // specifies the Name of Subnet
  network                  = var.vpc-id // specifies the ID of the VPC in which the subnet will be created, which is taken from the var.vpc-id variable.
  ip_cidr_range            = each.value["cidr"] // specifies the IP address range for the subnet, which is taken from the cidr attribute of each subnet specified in var.subnets. 
  private_ip_google_access = true // enables or disables access to Google services from instances in the subnet using their private IP addresses.
  region                   = var.region // specifies the region in which the subnet will be created
}