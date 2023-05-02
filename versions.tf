terraform {
  required_version = "~> 1.3"
  # backend "remote" {
  #   organization = "ijsvogel-retail"
  #   workspaces {
  #     name = "gcp-example"
  #   }
  # }
  required_providers {
    google = "~> 4.12"
  }
}
