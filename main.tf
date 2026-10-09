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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

variable "project_id" {
  description = "GCP project ID that the provider and all test resources use."
  type        = string
  default     = "hc-5d05572e92d6466c897a24b467f"
}

provider "google" {
  project = var.project_id
  region  = "us-central1" # Change to your preferred GCP region
}
