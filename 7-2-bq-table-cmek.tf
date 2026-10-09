# Test resources for policies/30/7-2-bq-table-cmek.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Tables reference datasets from 7-3-bq-dataset-cmek.tf by literal dataset_id.
#
# fail_bq_table_google_managed      -> violates the policy (no table CMEK; dataset has no default CMEK)
# pass_bq_table_own_cmek            -> complies with the policy (encryption_configuration.kms_key_name set)
# pass_bq_table_inherits_dataset_cmek -> complies with the policy (dataset in this plan has a default CMEK)
# pass_bq_logical_view              -> out of scope (logical views store no data)

resource "google_bigquery_table" "fail_bq_table_google_managed" {
  project             = var.project_id
  dataset_id          = "fail_bq_dataset_google_managed"
  table_id            = "fail_bq_table_google_managed"
  deletion_protection = false

  depends_on = [time_sleep.prerequisites_ready, google_bigquery_dataset.fail_bq_dataset_google_managed]
}

resource "google_bigquery_table" "pass_bq_table_own_cmek" {
  project             = var.project_id
  dataset_id          = "fail_bq_dataset_google_managed"
  table_id            = "pass_bq_table_own_cmek"
  deletion_protection = false
  encryption_configuration {
    kms_key_name = "projects/${var.project_id}/locations/us/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
  }

  depends_on = [time_sleep.prerequisites_ready, google_bigquery_dataset.fail_bq_dataset_google_managed]
}

resource "google_bigquery_table" "pass_bq_table_inherits_dataset_cmek" {
  project             = var.project_id
  dataset_id          = "pass_bq_dataset_cmek"
  table_id            = "pass_bq_table_inherits_dataset_cmek"
  deletion_protection = false

  depends_on = [time_sleep.prerequisites_ready, google_bigquery_dataset.pass_bq_dataset_cmek]
}

resource "google_bigquery_table" "pass_bq_logical_view" {
  project             = var.project_id
  dataset_id          = "fail_bq_dataset_google_managed"
  table_id            = "pass_bq_logical_view"
  deletion_protection = false
  view {
    query          = "SELECT 1 AS x"
    use_legacy_sql = false
  }

  depends_on = [time_sleep.prerequisites_ready, google_bigquery_dataset.fail_bq_dataset_google_managed]
}
