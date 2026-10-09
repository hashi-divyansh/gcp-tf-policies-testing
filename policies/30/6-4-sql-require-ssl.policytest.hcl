# Copyright IBM Corp. 2026

policytest {
  targets = ["6-4-sql-require-ssl.policy.hcl"]
}

resource "google_sql_database_instance" "pass_encrypted_only" {
  attrs = {
    name             = "pass-encrypted-only"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ssl_mode = "ENCRYPTED_ONLY"
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_trusted_client_certificate_required" {
  attrs = {
    name             = "pass-trusted-client-certificate-required"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ssl_mode = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_allow_unencrypted" {
  expect_failure = true
  attrs = {
    name             = "fail-allow-unencrypted"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      }]
    }]
  }
}

# Unset ssl_mode is equivalent to ALLOW_UNENCRYPTED_AND_ENCRYPTED.
resource "google_sql_database_instance" "fail_ssl_mode_unset" {
  expect_failure = true
  attrs = {
    name             = "fail-ssl-mode-unset"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled = false
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_no_ip_configuration" {
  expect_failure = true
  attrs = {
    name             = "fail-no-ip-configuration"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}
