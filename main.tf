terraform {
  required_version = ">=1.15.8"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "gcp_testing"
    }
  }

 required_providers {
      google = {
        source  = "hashicorp/google"
        version = "~> 6.0"
      }
 }
}

provider "google" {
  project = "hc-f31985686df247b5bbd6a432306"
  region  = "us-central1" # Change to your preferred GCP region
}

resource "google_storage_bucket" "my_bucket" {
  name          = "gcp-test-bucket-hc-f31985686df247b5bbd6a432306"
  location      = "US"
  force_destroy = true

  labels = {
    name        = "my-gcs-bucket"
    environment = "dev"
    managed_by  = "terraform"
  }
}

# Intentionally violates 3-6-restrict-ssh (allows SSH from 0.0.0.0/0).
# Remove or fix once you've confirmed the policy fails as expected.
resource "google_compute_network" "test_vpc" {
  name                    = "policy-test-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "fail_ssh_open_to_world" {
  name    = "fail-ssh-open-to-world"
  network = google_compute_network.test_vpc.name

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# resource "aws_s3_bucket" "my_bucket" {
#   # S3 bucket names must be globally unique across all AWS accounts
#   bucket = "aws-test-s3-025581115698-eu-north-1-an"
#   bucket_namespace = "account-regional"

#   tags = {
#     Name        = "My S3 Bucket"
#     Environment = "Dev"
#     ManagedBy   = "terraform"
#   }
# }
