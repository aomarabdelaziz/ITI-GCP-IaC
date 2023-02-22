/*
  This Terraform code creates a Google Compute Engine instance with the specified configuration.
*/

resource "google_compute_instance" "gke-instance-1" {
  name         = var.instance-name // specifies the name of the instance to the value of the instance-name variable.
  machine_type = var.machine-type // specifies the machine type of the instance to the value of the machine-type variable.
  zone         = var.zone // specifies the zone of the instance to the value of the zone variable.
  metadata_startup_script = file("${path.module}/script.sh") // specifies a startup script for the instance by reading the contents of a file located at ${path.module}/script.sh.

  // specifies the configuration for the boot disk of the instance.
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  // specifies the configuration for the network interface of the instance.
  network_interface {
    network    = var.vpc-name
    subnetwork = var.subnetwork-management-name
  }

  // specifies the service account for the instance to the value of the google-service-account-email variable and specifies the cloud-platform scope.
  service_account {
    email  = var.google-service-account-email
    scopes = ["cloud-platform"]
  }

}
