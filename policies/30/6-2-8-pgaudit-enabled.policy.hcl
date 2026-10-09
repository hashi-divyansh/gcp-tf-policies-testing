# Copyright IBM Corp. 2026

# Ensure That 'cloudsql.enable_pgaudit' Database Flag for each Cloud Sql Postgresql Instance Is Set to 'on' For Centralized Logging

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "pgaudit-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

# Only the flag is checked; CREATE EXTENSION pgaudit and audit logs are not visible in a plan.
resource_policy "google_sql_database_instance" "pgaudit_enabled" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "cloudsql.enable_pgaudit"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["on"], value)]
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.pgaudit-enabled-enforcement-level
  enforce {
    condition     = core::length(local.flag_values) > 0 && core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL PostgreSQL instances must set the 'cloudsql.enable_pgaudit' database flag to 'on'. The default is 'off'."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "pgaudit_enabled_dms_destination" {
  locals {
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["cloudsql.enable_pgaudit"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.pgaudit-enabled-enforcement-level
  enforce {
    condition     = core::contains(["on"], local.flag_value)
    error_message = "Database Migration Service connection profiles that create a Cloud SQL PostgreSQL destination instance must set the 'cloudsql.enable_pgaudit' flag in cloudsql.settings.database_flags to 'on'. The default is 'off'."
  }
}
