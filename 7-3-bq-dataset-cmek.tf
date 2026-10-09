# Test resources for policies/30/7-3-bq-dataset-cmek.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_bq_dataset_google_managed -> violates the policy (no default CMEK)
# pass_bq_dataset_cmek           -> complies with the policy (default_encryption_configuration.kms_key_name set)

resource "google_bigquery_dataset" "fail_bq_dataset_google_managed" {
  dataset_id                 = "fail_bq_dataset_google_managed"
  project                    = var.project_id
  location                   = "US"
  delete_contents_on_destroy = true
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_bigquery_dataset" "pass_bq_dataset_cmek" {
  dataset_id                 = "pass_bq_dataset_cmek"
  project                    = var.project_id
  location                   = "US"
  delete_contents_on_destroy = true
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  default_encryption_configuration {
    kms_key_name = "projects/${var.project_id}/locations/us/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
  }

  depends_on = [time_sleep.prerequisites_ready]
}
