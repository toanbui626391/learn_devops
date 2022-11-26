# terraform {
#   required_providers {
#     google = {
#       source = "hashicorp/google"
#     }
#   }
# }
# /* Set up and provide a service account with sufficient roles assigned.
# provider "google" {
#   alias = "impersonation"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# data "google_service_account_access_token" "default" {
#   provider               = google.impersonation
#   target_service_account = ""
#   scopes                 = ["userinfo-email", "cloud-platform"]
#   lifetime               = "1200s"
# }
# */

# provider "google" {
#   project         = "airflow-gke-338120-352104"
# #   access_token    = data.google_service_account_access_token.default.access_token
#   request_timeout = "60s"
# }

# resource "google_compute_instance" "default" {
#   name         = "wordpress-445691"
#   machine_type = "g1-small"
#   zone         = "us-west1-a"

#   metadata = {
#     enable-oslogin = "TRUE"
#   }
#   boot_disk {
#     initialize_params {
#       image = "projects/bitnami-launchpad/global/images/bitnami-wordpress-6-1-1-0-linux-debian-11-x86-64-nami"
#     }
#   }

#   network_interface {
#     network = "default"

#     access_config {
#       # Include this section to give the VM an external IP address
#     }
#   }
# }