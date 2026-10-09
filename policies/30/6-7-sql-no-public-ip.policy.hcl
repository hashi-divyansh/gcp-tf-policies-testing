# Copyright IBM Corp. 2026

# Ensure That Cloud SQL Database Instances Do Not Have Public IPs

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "sql-no-public-ip-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "no_public_ip" {
  locals {
    master_instance_name_raw = core::try(attrs.master_instance_name, null)
    master_instance_name     = local.master_instance_name_raw != null ? local.master_instance_name_raw : ""
    instance_type_raw        = core::try(attrs.instance_type, null)
    instance_type            = local.instance_type_raw != null ? core::upper(local.instance_type_raw) : ""
    # Read replicas are excluded. Set instance_type explicitly, or the result is unknown at plan.
    is_read_replica = local.instance_type != "" ? core::contains(["READ_REPLICA_INSTANCE", "READ_POOL_INSTANCE"], local.instance_type) : local.master_instance_name != ""

    # ipv4_enabled defaults to true (public IP) when unset.
    ipv4_enabled_raw    = core::try(attrs.settings[0].ip_configuration[0].ipv4_enabled, null)
    ipv4_enabled        = local.ipv4_enabled_raw != null ? local.ipv4_enabled_raw : true
    private_network_raw = core::try(attrs.settings[0].ip_configuration[0].private_network, null)
    private_network     = local.private_network_raw != null ? local.private_network_raw : ""
    # Private Service Connect counts as private connectivity. Only the psc_enabled leaves
    # are read because psc_config has computed fields.
    psc_enabled = core::contains(core::try(attrs.settings[0].ip_configuration[0].psc_config[*].psc_enabled, []), true)
  }

  filter = !local.is_read_replica

  enforcement_level = input.sql-no-public-ip-enforcement-level
  enforce {
    condition     = !local.ipv4_enabled && (local.private_network != "" || local.psc_enabled)
    error_message = "Cloud SQL instances must set settings.ip_configuration.ipv4_enabled = false and use private IP (settings.ip_configuration.private_network) or Private Service Connect (psc_config.psc_enabled = true)."
  }
}
