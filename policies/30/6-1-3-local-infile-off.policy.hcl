# Copyright IBM Corp. 2026

# Ensure That the 'Local_infile' Database Flag for a Cloud SQL MySQL Instance Is Set to 'Off'

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "local-infile-off-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "local_infile_off" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "local_infile"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["off"], value)]
  }

  filter = core::startswith(local.database_version, "MYSQL")

  enforcement_level = input.local-infile-off-enforcement-level
  enforce {
    condition     = core::length(local.flag_values) > 0 && core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL MySQL instances must set the 'local_infile' database flag to 'off'. The default is 'on'."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "local_infile_off_dms_destination" {
  locals {
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["local_infile"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "MYSQL")

  enforcement_level = input.local-infile-off-enforcement-level
  enforce {
    condition     = core::contains(["off"], local.flag_value)
    error_message = "Database Migration Service connection profiles that create a Cloud SQL MySQL destination instance must set the 'local_infile' flag in cloudsql.settings.database_flags to 'off'. The default is 'on'."
  }
}
