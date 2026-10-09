# Copyright IBM Corp. 2026

# Ensure That a Default Customer-Managed Encryption Key (CMEK) Is Specified for All BigQuery Data Sets

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "bq-dataset-cmek-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_bigquery_dataset" "dataset_default_cmek" {
  locals {
    kms_key_raw = core::try(attrs.default_encryption_configuration[0].kms_key_name, null)
    kms_key     = local.kms_key_raw != null ? core::trimspace(local.kms_key_raw) : ""
  }

  enforcement_level = input.bq-dataset-cmek-enforcement-level
  enforce {
    condition     = local.kms_key != ""
    error_message = "BigQuery datasets must set default_encryption_configuration.kms_key_name to a customer-managed Cloud KMS key."
  }
}
