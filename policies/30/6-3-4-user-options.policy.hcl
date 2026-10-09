# Copyright IBM Corp. 2026

# Ensure 'user options' Database Flag for Cloud SQL SQL Server Instance Is Not Configured

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "user-options-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "user_options_not_configured" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "user options"
    ]
  }

  filter = core::startswith(local.database_version, "SQLSERVER")

  enforcement_level = input.user-options-enforcement-level
  enforce {
    condition     = core::length(local.flag_values) == 0
    error_message = "Cloud SQL SQL Server instances must not configure the 'user options' database flag. Remove it from settings.database_flags."
  }
}
