# Copyright IBM Corp. 2026

# Ensure 'Skip_show_database' Database Flag for Cloud SQL MySQL Instance Is Set to 'On'

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "skip-show-database-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "skip_show_database_on" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "skip_show_database"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["on"], value)]
  }

  filter = core::startswith(local.database_version, "MYSQL")

  enforcement_level = input.skip-show-database-enforcement-level
  enforce {
    condition     = core::length(local.flag_values) > 0 && core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL MySQL instances must set the 'skip_show_database' database flag to 'on'. The default is 'off'."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "skip_show_database_on_dms_destination" {
  locals {
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["skip_show_database"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "MYSQL")

  enforcement_level = input.skip-show-database-enforcement-level
  enforce {
    condition     = core::contains(["on"], local.flag_value)
    error_message = "Database Migration Service connection profiles that create a Cloud SQL MySQL destination instance must set the 'skip_show_database' flag in cloudsql.settings.database_flags to 'on'. The default is 'off'."
  }
}
