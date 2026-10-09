# Copyright IBM Corp. 2026

# Ensure '3625 (trace flag)' Database Flag for all Cloud SQL SQL Server Instances Is Set to 'on'

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "trace-flag-3625-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "trace_flag_3625_on" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "3625"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["on"], value)]
  }

  filter = core::startswith(local.database_version, "SQLSERVER")

  enforcement_level = input.trace-flag-3625-enforcement-level
  enforce {
    condition     = core::length(local.flag_values) > 0 && core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL SQL Server instances must set the '3625' database flag to 'on'. The default is 'off'."
  }
}
