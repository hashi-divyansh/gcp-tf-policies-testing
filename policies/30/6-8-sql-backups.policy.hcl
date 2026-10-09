# Copyright IBM Corp. 2026

# Ensure That Cloud SQL Database Instances Are Configured With Automated Backups

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "sql-backups-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "automated_backups_enabled" {
  locals {
    master_instance_name_raw = core::try(attrs.master_instance_name, null)
    master_instance_name     = local.master_instance_name_raw != null ? local.master_instance_name_raw : ""
    instance_type_raw        = core::try(attrs.instance_type, null)
    instance_type            = local.instance_type_raw != null ? core::upper(local.instance_type_raw) : ""
    # Read replicas cannot have backups. Set instance_type explicitly, or the result is unknown at plan.
    is_read_replica = local.instance_type != "" ? core::contains(["READ_REPLICA_INSTANCE", "READ_POOL_INSTANCE"], local.instance_type) : local.master_instance_name != ""

    # Automated backups are not configured by default.
    backups_enabled_raw = core::try(attrs.settings[0].backup_configuration[0].enabled, null)
    backups_enabled     = local.backups_enabled_raw != null ? local.backups_enabled_raw : false
  }

  filter = !local.is_read_replica

  enforcement_level = input.sql-backups-enforcement-level
  enforce {
    condition     = local.backups_enabled
    error_message = "Cloud SQL instances (excluding read replicas) must set settings.backup_configuration.enabled = true to enable automated backups."
  }
}
