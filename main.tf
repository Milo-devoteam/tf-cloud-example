locals {
  environment = "dev"
  region      = "europe-west4"
  zone        = "europe-west4-a"
}

provider "google" {
  project = "pj-basic-tf-main"
  region  = "europe-west1"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-cloud-network"
}

resource "google_compute_subnetwork" "nl" {
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.self_link
  name          = "nwr-nl-dev"
  region        = local.region
}

module "compute_instance" {
  source = "git@github.com:ijsvogel/tf-modules.git//compute/compute_engine/v0.0.1"

  project_id          = "pj-basic-tf-main"
  num_instances       = 1
  hostname            = "web-server-vm"
  name_prefix         = "dev"
  subnetwork          = google_compute_subnetwork.nl.self_link
  region              = local.region
  zone                = local.zone
  deletion_protection = false
  enable_public_ip    = true
  machine_type        = "f1-micro" # Defaults to e2-small
  labels = {
    environment = "dev"
  }
  service_account = {
    email  = "1071561576304-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  network_tags = ["bastion-host"]

  metadata = {
    "enable-oslogin" = "FALSE"
  }

  startup_script = <<EOF
          apt install nginx
          EOF
}
