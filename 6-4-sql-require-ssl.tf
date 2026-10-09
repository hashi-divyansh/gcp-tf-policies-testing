# Test resources for policies/30/6-4-sql-require-ssl.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_sql_ssl_allow_unencrypted -> violates the policy (ssl_mode = ALLOW_UNENCRYPTED_AND_ENCRYPTED)
# pass_sql_ssl_encrypted_only    -> complies with the policy (ssl_mode = ENCRYPTED_ONLY)
# pass_sql_ssl_trusted_client    -> complies with the policy (ssl_mode = TRUSTED_CLIENT_CERTIFICATE_REQUIRED)
#
# ssl_mode is always set: it is computed (unknown at plan) when omitted.

resource "google_sql_database_instance" "fail_sql_ssl_allow_unencrypted" {
  name                = "fail-sql-ssl-allow-unencrypted"
  database_version    = "POSTGRES_15"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }
    database_flags {
      name  = "log_statement"
      value = "ddl"
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/policy-test-vpc"
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_ssl_encrypted_only" {
  name                = "pass-sql-ssl-encrypted-only"
  database_version    = "POSTGRES_15"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }
    database_flags {
      name  = "log_statement"
      value = "ddl"
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/policy-test-vpc"
      ssl_mode        = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_ssl_trusted_client" {
  name                = "pass-sql-ssl-trusted-client"
  database_version    = "MYSQL_8_0"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "skip_show_database"
      value = "on"
    }
    database_flags {
      name  = "local_infile"
      value = "off"
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/policy-test-vpc"
      ssl_mode        = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}
