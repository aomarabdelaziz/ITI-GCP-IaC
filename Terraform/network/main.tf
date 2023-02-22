/*
  This code defines a set of resources that configure networking infrastructure for a Google Cloud Platform (GCP) 
  project that will host a GKE cluster using Terraform.
*/


// This code block is using Terraform's google_project_service resource to enable or disable the compute.googleapis.com service for a GCP project.
resource "google_project_service" "compute" {
  /*
    The service attribute specifies the name of the GCP service that should be enabled or disabled. In this case, it is set to 
    "compute.googleapis.com", which corresponds to the Google Compute Engine service.
  */
  service = "compute.googleapis.com" 
  disable_dependent_services = true //The disable_dependent_services attribute is set to true, which means that any dependent services of Compute Engine will also be disabled. 
}
resource "google_project_service" "container" {
  
  /*
    The service attribute specifies the name of the GCP service that should be enabled or disabled. In this case, 
    it is set to "container.googleapis.com", which corresponds to the Google Kubernetes Engine (GKE) service.
  */
  service = "container.googleapis.com"
  disable_dependent_services = true //The disable_dependent_services attribute is set to true, which means that any dependent services of Compute Engine will also be disabled. 
}

/*
  This code block is using Terraform's google_compute_network resource to create a VPC network in Google Cloud Platform (GCP) for use with Google Kubernetes Engine (GKE).
*/
resource "google_compute_network" "gke-vpc" {
  name                    = var.vpc-name
  auto_create_subnetworks = false // attribute is set to false, which means that no subnetworks will be automatically created in the network. Instead, subnetworks will need to be explicitly created using separate google_compute_subnetwork resources.
 
 /* 
  attribute is set to a list of resources that the google_compute_network resource depends on. In this case, it depends on the google_project_service.compute and google_project_service.container resources. 
  This means that the google_compute_network resource will not be created until the compute.googleapis.com and container.googleapis.com services have been enabled for the project.
 */
 
  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

/*
  This code creates a Google Compute Engine router
*/
resource "google_compute_router" "gke-router" {
  name    = var.router-name // The router is associated with the Google Cloud region specified in the variable management-subnet-region, and the network it belongs to.
  region  = var.managemnt-subnet-region //  The region where the GCE router is located.
  network = google_compute_network.gke-vpc.id // references the google_compute_network resource named gke-vpc

  /*
    BGP is a protocol used to exchange routing information between different networks, and it's commonly used in large-scale networks. By default, when a Google Cloud router is created, 
    it will automatically propagate routes between subnetworks within the same VPC. However, if you want to route traffic to and from a network outside of the VPC, you'll need to configure BGP on the router.
  */
  bgp {
    asn = 64514
  }
}

/*
  This code creates a Google Compute Engine (GCE) router NAT configuration in a specified region for a VPC network.
*/
resource "google_compute_router_nat" "gke-nat" {
  name                               = var.nat-name // The name of the NAT configuration.
  router                             = google_compute_router.gke-router.name //  The name of the GCE router that the NAT configuration should be applied to.
  region                             = google_compute_router.gke-router.region //  The region where the GCE router is located.
  nat_ip_allocate_option             = "AUTO_ONLY" // Specifies the method used to allocate NAT IP addresses. In this case, it is set to "AUTO_ONLY", which means that Google Cloud Platform (GCP) will automatically allocate the NAT IP addresses.
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" // Specifies which subnetwork IP ranges are translated by the NAT. In this case, it is set to "ALL_SUBNETWORKS_ALL_IP_RANGES", which means that all subnetworks and IP ranges will be translated by the NAT.
}

/*
  This code creates a firewall rule named "ssh" in the Google Cloud Platform (GCP) project. 
  The firewall rule allows incoming traffic on TCP port 22 (SSH) from the specified source IP address range of "35.235.240.0/20".
*/
resource "google_compute_firewall" "ssh" {
  name    = "ssh" // sets the name of the firewall rule to "ssh".
  network = google_compute_network.gke-vpc.name // specifies the name of the network the firewall rule will be applied to, in this case, google_compute_network.gke-vpc.name, which is the name of the network created earlier.
  allow {
    protocol = "tcp" //  specifies the protocol being allowed, in this case, TCP.
    ports    = ["22"] // specifies the allowed port or ports for the specified protocol, in this case, port 22.
  }
  source_ranges = ["35.235.240.0/20"] // specifies the IP address range that is allowed to connect to the instance. In this case, incoming traffic is only allowed from the IP address range of "35.235.240.0/20".
}

/*
  This code creates a Google Compute Engine firewall rule that allows incoming HTTP traffic (on port 80) from any IP address to the specified network.

*/
resource "google_compute_firewall" "http" {
  name    = "http" // sets the name of the firewall rule to "http".
  network = google_compute_network.gke-vpc.name // google_compute_network.gke-vpc.name sets the network where the firewall rule should be applied. The value is obtained from the google_compute_network resource created earlier.
  
  // allows incoming TCP traffic on port 80.
  allow {
    protocol = "tcp"
    ports    = ["80"] 
  }
  source_ranges = ["0.0.0.0/0"] // ["0.0.0.0/0"] sets the source IP range for incoming traffic to any IP address, which is represented by 0.0.0.0/0. This means that incoming HTTP traffic will be allowed from any IP address.
}