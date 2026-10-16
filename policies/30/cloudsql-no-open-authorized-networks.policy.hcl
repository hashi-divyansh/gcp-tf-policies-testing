# Copyright IBM Corp. 2026

# Ensure That Cloud SQL Database Instances Do Not Implicitly Whitelist All Public IP Addresses

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "cloudsql-no-open-authorized-networks-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "no_open_authorized_networks" {
  locals {
    authorized_networks_raw = core::try(attrs.settings[0].ip_configuration[0].authorized_networks, null)
    authorized_networks     = local.authorized_networks_raw != null ? [for network in local.authorized_networks_raw : network] : []
    # Any /0 prefix (0.0.0.0/0, ::/0) allows all addresses. Split ranges are not detected.
    open_networks = [
      for network in local.authorized_networks : network
      if core::try(network.value, null) != null ? core::endswith(core::trimspace(network.value), "/0") : false
    ]
  }

  enforcement_level = input.cloudsql-no-open-authorized-networks-enforcement-level
  enforce {
    condition     = core::length(local.open_networks) == 0
    error_message = "Cloud SQL instances must not include an any-address range such as 0.0.0.0/0 or ::/0 in settings.ip_configuration.authorized_networks. Restrict access to trusted networks only."
  }
}

resource_policy "google_database_migration_service_connection_profile" "no_open_authorized_networks_dms_destination" {
  filter = core::try(core::length(attrs.cloudsql[0].settings), 0) > 0

  locals {
    authorized_networks_raw = core::try(attrs.cloudsql[0].settings[0].ip_config[0].authorized_networks, null)
    authorized_networks     = local.authorized_networks_raw != null ? [for network in local.authorized_networks_raw : network] : []
    open_networks = [
      for network in local.authorized_networks : network
      if core::try(network.value, null) != null ? core::endswith(core::trimspace(network.value), "/0") : false
    ]
  }

  enforcement_level = input.cloudsql-no-open-authorized-networks-enforcement-level
  enforce {
    condition     = core::length(local.open_networks) == 0
    error_message = "Database Migration Service connection profiles that create a Cloud SQL destination must not include an any-address range such as 0.0.0.0/0 or ::/0 in cloudsql.settings.ip_config.authorized_networks."
  }
}
