# Copyright IBM Corp. 2026

# Ensure 'user Connections' Database Flag for Cloud SQL SQL Server Instance Is Set to a Non-limiting Value

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "user-connections-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "user_connections_non_limiting" {
  locals {
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "user connections"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(["0"], value)]
  }

  filter = core::startswith(local.database_version, "SQLSERVER")

  enforcement_level = input.user-connections-enforcement-level
  enforce {
    condition     = core::length(local.non_compliant_values) == 0
    error_message = "Cloud SQL SQL Server instances must leave the 'user connections' database flag unset or set it to '0'. The default ('0', non-limiting) is compliant."
  }
}
