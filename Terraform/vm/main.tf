resource "google_compute_instance" "gke-instance-1" {
  name         = var.instance-name
  machine_type = var.machine-type
  zone         = var.zone
  metadata_startup_script = file("${path.module}/script.sh")

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    network    = var.vpc-name
    subnetwork = var.subnetwork-management-name
  }
  service_account {
    email  = var.google-service-account-email
    scopes = ["cloud-platform"]
  }

}
