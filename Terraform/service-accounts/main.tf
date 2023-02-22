/*
  This Terraform code defines four resources related to Google Cloud Platform (GCP) service accounts and their permissions:
  Overall, this code creates two service accounts with different permissions in the current GCP project. 
  It's common practice to limit the permissions of a service account to the minimum required to perform its intended tasks, 
  and these resources help achieve that by granting the necessary roles to each service account.
*/

// This resource creates a new service account in the current project with an ID of custom-compute-sa and a display name of Custom Compute Service Account.
resource "google_service_account" "custom_compute_sa" { 
  account_id   = "custom-compute-sa"
  display_name = "Custom Compute Service Account"
}
// This resource creates a new service account in the current project with an ID of custom-gke-sa and a display name of Custom GKE Service Account.
resource "google_service_account" "custom_gke_sa" { 
  account_id   = "custom-gke-sa"
  display_name = "Custom GKE Service Account"
}
 
 // This resource grants the roles/container.admin role to the custom-compute-sa service account for the current project. This role allows the service account to administer GKE clusters.
resource "google_project_iam_member" "compute_sa" {
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.custom_compute_sa.email}"
  project = google_service_account.custom_compute_sa.project
}


// This resource grants the roles/storage.objectViewer role to the custom-gke-sa service account for the current project. This role allows the service account to view objects in Cloud Storage buckets.
resource "google_project_iam_member" "gke_sa" { 
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.custom_gke_sa.email}"
  project = google_service_account.custom_gke_sa.project
}