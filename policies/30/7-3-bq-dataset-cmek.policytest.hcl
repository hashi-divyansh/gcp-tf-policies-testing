# Copyright IBM Corp. 2026

policytest {
  targets = ["7-3-bq-dataset-cmek.policy.hcl"]
}

resource "google_bigquery_dataset" "pass_default_cmek" {
  attrs = {
    dataset_id                       = "pass_default_cmek"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

# Google-managed keys are used when no default CMEK is set.
resource "google_bigquery_dataset" "fail_no_default_encryption" {
  expect_failure = true
  attrs = {
    dataset_id = "fail_no_default_encryption"
    location   = "US"
  }
}

resource "google_bigquery_dataset" "fail_empty_kms_key_name" {
  expect_failure = true
  attrs = {
    dataset_id                       = "fail_empty_kms_key_name"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "" }]
  }
}

resource "google_bigquery_dataset" "fail_blank_kms_key_name" {
  expect_failure = true
  attrs = {
    dataset_id                       = "fail_blank_kms_key_name"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = " " }]
  }
}
