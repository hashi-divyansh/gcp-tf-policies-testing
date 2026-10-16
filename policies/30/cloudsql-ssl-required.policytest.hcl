# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudsql-ssl-required.policy.hcl"]
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

# Without a legacy require_ssl value, an unset ssl_mode allows unencrypted traffic.
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

resource "google_sql_database_instance" "pass_sqlserver_encrypted_only" {
  attrs = {
    name             = "pass-sqlserver-encrypted-only"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier             = "db-custom-2-7680"
      ip_configuration = [{ ssl_mode = "ENCRYPTED_ONLY" }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_requires_ssl" {
  attrs = {
    connection_profile_id = "pass-dms-requires-ssl"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ require_ssl = true }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_postgres_requires_ssl" {
  attrs = {
    connection_profile_id = "pass-dms-postgres-requires-ssl"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ require_ssl = true }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_allows_unencrypted" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-allows-unencrypted"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ require_ssl = false }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_ssl_omitted" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-ssl-omitted"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ enable_ipv4 = true }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_no_ip_config" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-no-ip-config"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_null_ssl" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-null-ssl"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ require_ssl = null }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_mysql_source_out_of_scope" {
  attrs = {
    connection_profile_id = "pass-mysql-source-out-of-scope"
    location              = "us-central1"
    mysql                 = [{ host = "192.0.2.10", port = 3306, username = "migration" }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_existing_destination_out_of_scope" {
  attrs = {
    connection_profile_id = "pass-existing-destination-out-of-scope"
    location              = "us-central1"
    cloudsql              = [{ cloud_sql_id = "existing-instance" }]
  }
}
