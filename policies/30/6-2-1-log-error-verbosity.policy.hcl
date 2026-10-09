# Copyright IBM Corp. 2026

# Ensure 'Log_error_verbosity' Database Flag for Cloud SQL PostgreSQL Instance Is Set to 'DEFAULT' or Stricter

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "log-error-verbosity-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "log_error_verbosity_default_or_stricter" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "log_error_verbosity"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["default", "terse"], value)]
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-error-verbosity-enforcement-level
  enforce {
    condition     = core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL PostgreSQL instances must leave the 'log_error_verbosity' database flag unset or set it to one of 'default', 'terse'. The default ('default') is compliant."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "log_error_verbosity_default_or_stricter_dms_destination" {
  locals {
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["log_error_verbosity"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-error-verbosity-enforcement-level
  enforce {
    condition     = local.flag_value_raw == null || core::contains(["default", "terse"], local.flag_value)
    error_message = "Database Migration Service connection profiles that create a Cloud SQL PostgreSQL destination instance must leave the 'log_error_verbosity' flag in cloudsql.settings.database_flags unset or set it to one of 'default', 'terse'. The default ('default') is compliant."
  }
}
