terraform {
  required_version = ">=1.17.0"

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
