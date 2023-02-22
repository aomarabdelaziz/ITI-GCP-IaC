/*
  This code is written in HashiCorp Configuration Language (HCL) and uses Terraform to create a Google Kubernetes Engine (GKE) cluster 
  and a node pool within the cluster. Let's break it down into two resources:
*/

// google_container_cluster: This resource creates a GKE cluster with the following properties:
resource "google_container_cluster" "gke-1" {
  name                     = var.gke-name // The name of the GKE cluster.
  location                 = var.region // The region/zone in which the cluster will be created.
  remove_default_node_pool = true // This specifies whether the default node pool should be removed or not.
  initial_node_count       = 1 // The initial number of nodes to create in the node pool.
  network                  = var.vpc-name // The VPC network to use for the GKE cluster.
  subnetwork               = var.restricted-subnet-name // The subnet within the VPC network to use for the GKE cluster
  ip_allocation_policy {
  }

  // This is an optional block that enables the cluster to be private.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master-ipv4-cidr-block
  }
  // This is an optional block that specifies the CIDR blocks from which the GKE master can be accessed.
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/24"
      display_name = "Management Subnet"
    }
  }
}

// This resource creates a node pool within the GKE cluster including preemptible status, machine type, and OAuth scopes.
resource "google_container_node_pool" "gke-1_node_pool" {
  name       = var.gke-node-name // The name of the node pool.
  location   = var.region // The region/zone in which the node pool will be created.
  cluster    = google_container_cluster.gke-1.name // The name of the GKE cluster where the node pool will be created.
  node_count = 1 // The number of nodes to create in the node pool.
  
  // This block specifies the configuration for the nodes in the node pool, including preemptible status, machine type, and OAuth scopes. 
  node_config {
    preemptible     = true
    machine_type    = var.machine-type
    service_account = var.google-service-account-email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}