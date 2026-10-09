# Copyright IBM Corp. 2026

# Ensure 'Log_min_error_statement' Database Flag for Cloud SQL PostgreSQL Instance Is Set to 'Error' or Stricter

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "log-min-error-statement-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "log_min_error_statement_error_or_stricter" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "log_min_error_statement"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["error", "log", "fatal", "panic"], value)]
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-min-error-statement-enforcement-level
  enforce {
    condition     = core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL PostgreSQL instances must leave the 'log_min_error_statement' database flag unset or set it to one of 'error', 'log', 'fatal', 'panic'. The default ('error') is compliant."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "log_min_error_statement_error_or_stricter_dms_destination" {
  locals {
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["log_min_error_statement"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-min-error-statement-enforcement-level
  enforce {
    condition     = local.flag_value_raw == null || core::contains(["error", "log", "fatal", "panic"], local.flag_value)
    error_message = "Database Migration Service connection profiles that create a Cloud SQL PostgreSQL destination instance must leave the 'log_min_error_statement' flag in cloudsql.settings.database_flags unset or set it to one of 'error', 'log', 'fatal', 'panic'. The default ('error') is compliant."
  }
}
