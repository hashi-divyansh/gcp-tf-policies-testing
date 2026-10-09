# Copyright IBM Corp. 2026

# Ensure 'Log_statement' Database Flag for Cloud SQL PostgreSQL Instance Is Set Appropriately

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "log-statement-enforcement-level" {
  type    = string
  default = "advisory"
}

# CIS recommends 'ddl'; override to match your logging policy.
input "log-statement-allowed-values" {
  type    = list(string)
  default = ["ddl"]
}

resource_policy "google_sql_database_instance" "log_statement_set_appropriately" {
  locals {
    allowed_values       = [for value in input.log-statement-allowed-values : core::lower(value)]
    database_version_raw = core::try(attrs.database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    database_flags_raw   = core::try(attrs.settings[0].database_flags, null)
    database_flags       = local.database_flags_raw != null ? [for flag in local.database_flags_raw : flag] : []
    # Case-insensitive; the ternary guards core::lower against null.
    flag_values = [
      for flag in local.database_flags : (core::try(flag.value, null) != null ? core::lower(core::trimspace(flag.value)) : "")
      if core::try(flag.name, null) == "log_statement"
    ]
    non_compliant_values = [for value in local.flag_values : value if !core::contains(local.allowed_values, value)]
    # Unset means the default 'none'.
    compliant = core::length(local.flag_values) > 0 ? core::length(local.non_compliant_values) == 0 : core::contains(local.allowed_values, "none")
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-statement-enforcement-level
  enforce {
    condition     = local.compliant
    error_message = "Cloud SQL PostgreSQL instances must set the 'log_statement' database flag to an approved value (default: 'ddl'). The default ('none') logs no statements."
  }
}

# DMS connection profiles that create a Cloud SQL destination instance.
resource_policy "google_database_migration_service_connection_profile" "log_statement_set_appropriately_dms_destination" {
  locals {
    allowed_values       = [for value in input.log-statement-allowed-values : core::lower(value)]
    database_version_raw = core::try(attrs.cloudsql[0].settings[0].database_version, null)
    database_version     = local.database_version_raw != null ? core::upper(local.database_version_raw) : ""
    flag_value_raw       = core::try(attrs.cloudsql[0].settings[0].database_flags["log_statement"], null)
    flag_value           = local.flag_value_raw != null ? core::lower(core::trimspace(local.flag_value_raw)) : ""
  }

  filter = core::startswith(local.database_version, "POSTGRES")

  enforcement_level = input.log-statement-enforcement-level
  enforce {
    condition     = local.flag_value_raw != null ? core::contains(local.allowed_values, local.flag_value) : core::contains(local.allowed_values, "none")
    error_message = "Database Migration Service connection profiles that create a Cloud SQL PostgreSQL destination instance must set the 'log_statement' flag in cloudsql.settings.database_flags to an approved value (default: 'ddl'). The default ('none') logs no statements."
  }
}
