# Copyright IBM Corp. 2026

# Ensure That the Cloud SQL Database Instance Requires All Incoming Connections To Use SSL

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "cloudsql-ssl-required-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "require_ssl_connections" {
  locals {
    ssl_mode_raw = core::try(attrs.settings[0].ip_configuration[0].ssl_mode, null)
    ssl_mode     = local.ssl_mode_raw != null ? core::upper(local.ssl_mode_raw) : ""
    # ssl_mode takes precedence; require_ssl is only available on instances in v6.
    legacy_require_ssl = core::try(attrs.settings[0].ip_configuration[0].require_ssl, null) == true
    encrypted_only     = local.ssl_mode != "" ? core::contains(["ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"], local.ssl_mode) : local.legacy_require_ssl
  }

  enforcement_level = input.cloudsql-ssl-required-enforcement-level
  enforce {
    condition     = local.encrypted_only
    error_message = "Cloud SQL instances must set settings.ip_configuration.ssl_mode to 'ENCRYPTED_ONLY' or 'TRUSTED_CLIENT_CERTIFICATE_REQUIRED', or use require_ssl = true with no ssl_mode on provider v6."
  }
}

resource_policy "google_database_migration_service_connection_profile" "require_ssl_connections_dms_destination" {
  filter = core::try(core::length(attrs.cloudsql[0].settings), 0) > 0

  locals {
    require_ssl_raw = core::try(attrs.cloudsql[0].settings[0].ip_config[0].require_ssl, null)
    require_ssl     = local.require_ssl_raw != null ? local.require_ssl_raw : false
  }

  enforcement_level = input.cloudsql-ssl-required-enforcement-level
  enforce {
    condition     = local.require_ssl
    error_message = "Database Migration Service connection profiles that create a Cloud SQL destination must set cloudsql.settings.ip_config.require_ssl = true."
  }
}
