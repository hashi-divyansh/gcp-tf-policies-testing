# Copyright IBM Corp. 2026

# Ensure That Cloud Storage Buckets Have Uniform Bucket-Level Access Enabled

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "uniform-bucket-access-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_storage_bucket" "uniform_bucket_level_access_enabled" {
  locals {
    # Disabled by default. An omitted value is unknown at plan, so set it explicitly.
    ubla_raw = core::try(attrs.uniform_bucket_level_access, null)
    ubla     = local.ubla_raw != null ? local.ubla_raw : false
  }

  enforcement_level = input.uniform-bucket-access-enforcement-level
  enforce {
    condition     = local.ubla
    error_message = "Cloud Storage buckets must set uniform_bucket_level_access = true."
  }
}
