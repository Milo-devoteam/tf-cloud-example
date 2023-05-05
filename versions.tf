terraform {
  required_version = "~> 1.3"
  backend "remote" {
    organization = "ijsvogelretail"
    workspaces {
      name = "gcp-example"
    }
  }
  required_providers {
    google = "~> 4.12"
  }
}
