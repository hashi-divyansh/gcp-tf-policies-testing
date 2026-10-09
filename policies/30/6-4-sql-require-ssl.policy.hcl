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

input "sql-require-ssl-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_sql_database_instance" "require_ssl_connections" {
  locals {
    # An unset ssl_mode allows unencrypted connections. require_ssl was removed in v7.
    ssl_mode_raw = core::try(attrs.settings[0].ip_configuration[0].ssl_mode, null)
    ssl_mode     = local.ssl_mode_raw != null ? core::upper(local.ssl_mode_raw) : "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
  }

  enforcement_level = input.sql-require-ssl-enforcement-level
  enforce {
    condition     = core::contains(["ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"], local.ssl_mode)
    error_message = "Cloud SQL instances must set settings.ip_configuration.ssl_mode to 'ENCRYPTED_ONLY' or 'TRUSTED_CLIENT_CERTIFICATE_REQUIRED'. An unset ssl_mode allows unencrypted connections."
  }
}
