# Copyright IBM Corp. 2026

# Ensure 'cross db ownership chaining' Database Flag for Cloud SQL SQL Server Instance Is Set to 'off'

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "cross-db-chaining-off-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "cross_db_ownership_chaining_off" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "cross db ownership chaining"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["off"], value)]
  }

  filter = core::startswith(local.database_version, "SQLSERVER")

  enforcement_level = input.cross-db-chaining-off-enforcement-level
  enforce {
    condition     = core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL SQL Server instances must leave the 'cross db ownership chaining' database flag unset or set it to 'off'. The flag is deprecated; an unset flag is compliant."
  }
}
