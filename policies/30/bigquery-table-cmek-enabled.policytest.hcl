# Copyright IBM Corp. 2026

policytest {
  targets = ["bigquery-table-cmek-enabled.policy.hcl"]
}

# Supporting datasets referenced by the table cases below.
resource "google_bigquery_dataset" "cmek_dataset" {
  attrs = {
    project                          = "example-project"
    dataset_id                       = "cmek_dataset"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_dataset" "cmek_dataset_in_project_a" {
  attrs = {
    dataset_id                       = "project_a_dataset"
    project                          = "project-a"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_dataset" "google_managed_dataset" {
  attrs = {
    dataset_id = "google_managed_dataset"
    location   = "US"
  }
}

resource "google_bigquery_table" "pass_table_cmek" {
  attrs = {
    dataset_id               = "google_managed_dataset"
    table_id                 = "pass_table_cmek"
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

# New tables inherit the dataset's default CMEK.
resource "google_bigquery_table" "pass_inherits_dataset_cmek" {
  attrs = {
    project    = "example-project"
    dataset_id = "cmek_dataset"
    table_id   = "pass_inherits_dataset_cmek"
  }
}

resource "google_bigquery_table" "pass_inherits_dataset_cmek_same_project" {
  attrs = {
    dataset_id = "project_a_dataset"
    table_id   = "pass_inherits_dataset_cmek_same_project"
    project    = "project-a"
  }
}

resource "google_bigquery_table" "fail_google_managed_key" {
  expect_failure = true
  attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "fail_google_managed_key"
  }
}

# Without a CMEK dataset in the plan, the table must set its own key.
resource "google_bigquery_table" "fail_dataset_not_in_plan" {
  expect_failure = true
  attrs = {
    dataset_id = "external_dataset"
    table_id   = "fail_dataset_not_in_plan"
  }
}

# A CMEK dataset with the same dataset_id in a different project does not apply.
resource "google_bigquery_table" "fail_same_dataset_id_in_other_project" {
  expect_failure = true
  attrs = {
    dataset_id = "project_a_dataset"
    table_id   = "fail_same_dataset_id_in_other_project"
    project    = "project-b"
  }
}

# Logical views store no data, so CMEK does not apply.
resource "google_bigquery_table" "pass_logical_view_out_of_scope" {
  attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "pass_logical_view_out_of_scope"
    view       = [{ query = "SELECT 1", use_legacy_sql = false }]
  }
}

resource "google_bigquery_table" "pass_external_table_out_of_scope" {
  attrs = {
    dataset_id = "plain_dataset"
    table_id   = "external_csv"
    external_data_configuration = [{
      autodetect    = true
      source_format = "CSV"
      source_uris   = ["gs://example-bucket/data/*.csv"]
    }]
  }
}

# A table's own key is enough even when its dataset is not in the plan.
resource "google_bigquery_table" "pass_own_key_dataset_not_in_plan" {
  attrs = {
    dataset_id               = "external_dataset"
    table_id                 = "pass_own_key_dataset_not_in_plan"
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_table" "fail_blank_table_kms_key" {
  expect_failure = true
  attrs = {
    dataset_id               = "google_managed_dataset"
    table_id                 = "fail_blank_table_kms_key"
    encryption_configuration = [{ kms_key_name = " " }]
  }
}

resource "google_bigquery_dataset" "blank_key_dataset" {
  attrs = {
    project                          = "example-project"
    dataset_id                       = "blank_key_dataset"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = " " }]
  }
}

# A blank dataset default key is not a customer-managed key to inherit.
resource "google_bigquery_table" "fail_dataset_blank_default_key" {
  expect_failure = true
  attrs = {
    project    = "example-project"
    dataset_id = "blank_key_dataset"
    table_id   = "fail_dataset_blank_default_key"
  }
}

# Materialized views store data in BigQuery, so they stay in scope.
resource "google_bigquery_table" "fail_materialized_view_google_managed" {
  expect_failure = true
  attrs = {
    dataset_id        = "google_managed_dataset"
    table_id          = "fail_materialized_view_google_managed"
    materialized_view = [{ query = "SELECT 1 AS x" }]
  }
}

resource "google_bigquery_table" "pass_materialized_view_inherits_dataset_cmek" {
  attrs = {
    project           = "example-project"
    dataset_id        = "cmek_dataset"
    table_id          = "pass_materialized_view_inherits_dataset_cmek"
    materialized_view = [{ query = "SELECT 1 AS x" }]
  }
}

resource "google_bigquery_dataset" "existing_dataset_adds_default_cmek" {
  prior_attrs = {
    project                          = "example-project"
    dataset_id                       = "existing_dataset"
    location                         = "US"
    default_encryption_configuration = []
  }
  attrs = {
    project                          = "example-project"
    dataset_id                       = "existing_dataset"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_table" "fail_existing_table_after_dataset_default_added" {
  expect_failure = true
  prior_attrs = {
    project                  = "example-project"
    dataset_id               = "existing_dataset"
    table_id                 = "existing_table"
    description              = "Before"
    encryption_configuration = []
  }
  attrs = {
    project                  = "example-project"
    dataset_id               = "existing_dataset"
    table_id                 = "existing_table"
    description              = "After"
    encryption_configuration = []
  }
}

resource "google_bigquery_table" "pass_new_table_after_dataset_default_added" {
  attrs = {
    project    = "example-project"
    dataset_id = "existing_dataset"
    table_id   = "new_table"
  }
}

resource "google_bigquery_table" "pass_update_with_table_cmek" {
  prior_attrs = {
    project                  = "example-project"
    dataset_id               = "existing_dataset"
    table_id                 = "encrypted_table"
    description              = "Before"
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
  attrs = {
    project                  = "example-project"
    dataset_id               = "existing_dataset"
    table_id                 = "encrypted_table"
    description              = "After"
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_table" "fail_update_with_blank_table_key" {
  expect_failure = true
  prior_attrs = {
    project    = "example-project"
    dataset_id = "existing_dataset"
    table_id   = "blank_key_update"
  }
  attrs = {
    project                  = "example-project"
    dataset_id               = "existing_dataset"
    table_id                 = "blank_key_update"
    encryption_configuration = [{ kms_key_name = " " }]
  }
}

resource "google_bigquery_table" "pass_logical_view_update_out_of_scope" {
  prior_attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "logical_view"
    view       = [{ query = "SELECT 1 AS x", use_legacy_sql = false }]
  }
  attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "logical_view"
    view       = [{ query = "SELECT 2 AS x", use_legacy_sql = false }]
  }
}

resource "google_bigquery_table" "pass_external_table_update_out_of_scope" {
  prior_attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "external_table"
    external_data_configuration = [{
      autodetect    = true
      source_format = "CSV"
      source_uris   = ["gs://example-bucket/before/*.csv"]
    }]
  }
  attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "external_table"
    external_data_configuration = [{
      autodetect    = true
      source_format = "CSV"
      source_uris   = ["gs://example-bucket/after/*.csv"]
    }]
  }
}

resource "google_bigquery_table" "fail_materialized_view_update_without_table_key" {
  expect_failure = true
  prior_attrs = {
    project           = "example-project"
    dataset_id        = "existing_dataset"
    table_id          = "materialized_view"
    description       = "Before"
    materialized_view = [{ query = "SELECT 1 AS x" }]
  }
  attrs = {
    project           = "example-project"
    dataset_id        = "existing_dataset"
    table_id          = "materialized_view"
    description       = "After"
    materialized_view = [{ query = "SELECT 1 AS x" }]
  }
}

resource "google_bigquery_table" "fail_missing_table_project" {
  expect_failure = true
  attrs = {
    dataset_id = "cmek_dataset"
    table_id   = "missing_project"
  }
}

resource "google_bigquery_dataset" "cmek_dataset_without_project" {
  attrs = {
    dataset_id                       = "missing_project_dataset"
    location                         = "US"
    default_encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_table" "fail_missing_dataset_project" {
  expect_failure = true
  attrs = {
    project    = "example-project"
    dataset_id = "missing_project_dataset"
    table_id   = "missing_dataset_project"
  }
}

resource "google_bigquery_table" "fail_both_projects_missing" {
  expect_failure = true
  attrs = {
    dataset_id = "missing_project_dataset"
    table_id   = "both_projects_missing"
  }
}

resource "google_bigquery_table" "pass_materialized_view_update_with_table_key" {
  prior_attrs = {
    dataset_id               = "google_managed_dataset"
    table_id                 = "encrypted_materialized_view"
    description              = "Before"
    materialized_view        = [{ query = "SELECT 1 AS x" }]
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
  attrs = {
    dataset_id               = "google_managed_dataset"
    table_id                 = "encrypted_materialized_view"
    description              = "After"
    materialized_view        = [{ query = "SELECT 1 AS x" }]
    encryption_configuration = [{ kms_key_name = "projects/example-project/locations/us/keyRings/bq-ring/cryptoKeys/bq-key" }]
  }
}

resource "google_bigquery_table" "pass_delete_unencrypted_table" {
  prior_attrs = {
    dataset_id = "google_managed_dataset"
    table_id   = "deleted_table"
  }
  attrs = null
}
