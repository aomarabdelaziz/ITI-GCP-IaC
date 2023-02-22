/*
  This Terraform code to create a Google Kubernetes Engine (GKE) cluster and a node pool within the cluster.
*/

// google_container_cluster: This resource creates a GKE cluster with the following properties:
resource "google_container_cluster" "gke-1" {
  name                     = var.gke-name // The name of the GKE cluster.
  location                 = var.region // The region/zone in which the cluster will be created.
  remove_default_node_pool = true // This specifies whether the default node pool should be removed or not.
  initial_node_count       = 1 // The initial number of nodes to create in the node pool.
  network                  = var.vpc-name // The VPC network to use for the GKE cluster.
  subnetwork               = var.restricted-subnet-name // The subnet within the VPC network to use for the GKE cluster

  // This is an optional block that enables the cluster to be private.
  private_cluster_config {
    enable_private_nodes    = true // This boolean value indicates whether or not private nodes are enabled for the cluster.
    enable_private_endpoint = true // This boolean value indicates whether or not a private endpoint is enabled for the cluster
    master_ipv4_cidr_block  = var.master-ipv4-cidr-block // This specifies the IPv4 CIDR block for the master endpoint in the cluster.
  }
   /*
     This is an optional block that specifies the CIDR blocks from which the GKE master can be accessed.
     is used to specify authorized networks for accessing the GKE cluster's Kubernetes master. By setting the cidr_blocks list to include the specified CIDR block,
     traffic from the Management Subnet will be allowed to access the Kubernetes master.
   */
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/24" // defines a list of authorized CIDR blocks. In this case, there is only one entry with cidr_block set to "10.0.0.0/24
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
    preemptible     = true // is a boolean that specifies whether the nodes should be preemptible or not.
    machine_type    = var.machine-type // specifies the type of machine that should be used for each node.
    service_account = var.google-service-account-email // specifies the email address of the Google Cloud service account that will be used to run the node VMs
    /*
    is a list of OAuth scopes that should be granted to the nodes. In this case, the cloud-platform scope is being granted, which gives the nodes access to all Cloud APIs.
    */
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}