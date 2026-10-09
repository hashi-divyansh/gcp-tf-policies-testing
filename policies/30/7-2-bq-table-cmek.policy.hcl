# Copyright IBM Corp. 2026

# Ensure That All BigQuery Tables Are Encrypted With Customer-Managed Encryption Key (CMEK)

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "bq-table-cmek-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  # Tables inherit the default CMEK of a dataset in the same plan.
  bq_all_datasets = core::getresources("google_bigquery_dataset", {})
  # Not filtered by key, so an unknown key only affects its own dataset's tables.
  bq_datasets = [
    for dataset in local.bq_all_datasets : {
      dataset_id   = core::try(dataset.dataset_id, null) != null ? dataset.dataset_id : ""
      project      = core::try(dataset.project, null) != null ? dataset.project : ""
      kms_key_name = core::try(dataset.default_encryption_configuration[0].kms_key_name, null) != null ? core::trimspace(dataset.default_encryption_configuration[0].kms_key_name) : ""
    }
  ]
}

resource_policy "google_bigquery_table" "table_encrypted_with_cmek" {
  locals {
    # Views store no data. Test lengths: try() is unknown for partially-unknown blocks.
    is_view = core::try(core::length(attrs.view), 0) > 0
    # External and BigLake tables store data outside BigQuery. biglake_configuration is v7 only.
    is_external = core::try(core::length(attrs.external_data_configuration), 0) > 0 || core::try(core::length(attrs.biglake_configuration), 0) > 0

    table_kms_key_raw = core::try(attrs.encryption_configuration[0].kms_key_name, null)
    table_kms_key     = local.table_kms_key_raw != null ? core::trimspace(local.table_kms_key_raw) : ""
    dataset_id_raw    = core::try(attrs.dataset_id, null)
    dataset_id        = local.dataset_id_raw != null ? local.dataset_id_raw : ""
    project_raw       = core::try(attrs.project, null)
    project           = local.project_raw != null ? local.project_raw : ""

    # An empty project means the provider default project.
    own_datasets = [
      for dataset in local.bq_datasets : dataset
      if dataset.dataset_id == local.dataset_id && local.dataset_id != "" && (dataset.project == local.project || dataset.project == "" || local.project == "")
    ]
    # Ternary, not ||, so the table's own key decides even if the dataset key is unknown.
    has_cmek = local.table_kms_key != "" ? true : core::length([for dataset in local.own_datasets : dataset if dataset.kms_key_name != ""]) > 0
  }

  filter = !local.is_view && !local.is_external

  enforcement_level = input.bq-table-cmek-enforcement-level
  enforce {
    condition     = local.has_cmek
    error_message = "BigQuery tables must be encrypted with a customer-managed key: set encryption_configuration.kms_key_name, or create the table in a dataset that sets default_encryption_configuration.kms_key_name."
  }
}
