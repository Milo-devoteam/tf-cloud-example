locals {
  environment = "dev"
  region      = "europe-west4"
  zone        = "europe-west4-a"
  project     = "pj-basic-tf-main"
}

provider "google" {
  project = local.project
  region  = local.region
}

module "network" {
  source = "git@github.com:ijsvogel/tf-modules.git//network/basic"

  vpcs = {
    "nw-dev-example" = {
      project      = local.project
      description  = "VPC Network for Ijsvogel prod"
      routing_mode = "REGIONAL"
      environment  = local.environment
      name         = "example"

      skip_default_deny_fw = true # Default deny all egress rule
      subnets = {
        "nwr-nl" = {
          name                  = "nl"
          region                = local.region
          cidr_primary          = "10.0.0.0/24"
          private_google_access = true
          secondary_ranges      = {}
        }
      }
    }
  }
  firewalls = {
    "nw-dev-example" = {
      project           = local.project
      network           = "nw-dev-example"
      ingress_allow_tag = {} # Used For internal communication (vm -> vm inside same VPC)
      ingress_allow_range = {
        "fw-allow-ssh-http" = {
          description   = "Allow SSH from public to bastion"
          source_ranges = ["0.0.0.0/0"]
          priority      = 1000
          target_tags   = []
          protocols = {
            "tcp" = ["22", "80"]
          }
        }
      }
      egress_allow_range = {
        # Allow all internal networking
        "fw-allow-all" = {
          description        = "Allow egress for all"
          destination_ranges = ["0.0.0.0/0"]
          priority           = 997
          target_tags        = []
          protocols = {
            "all" = []
          }
        }
      }
      egress_deny_range = {}
    }
  }
}

module "compute_instance" {
  source = "git@github.com:ijsvogel/tf-modules.git//compute/compute_engine/v0.0.1"

  project_id          = "pj-basic-tf-main"
  num_instances       = 1
  hostname            = "web-server-vm"
  name_prefix         = "dev"
  subnetwork          = module.network.sub_networks["nw-dev-example"]["nwr-nl"].self_link
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
          curl https://github.com/Milo-devoteam/whalesayer/releases/download/v0.1.0/whalesayer-amd64 -Lo /usr/local/bin/whalesayer
          sudo chmod 755 /usr/local/bin/whalesayer
          export COW_PATH=/usr/share/cowsay/cows
          export PORT=8080
          whalesayer
          EOF
}
