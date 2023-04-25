provider "google" {
  project = "pj-basic-tf-main"
  region  = "europe-west1"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-cloud-network"
}
