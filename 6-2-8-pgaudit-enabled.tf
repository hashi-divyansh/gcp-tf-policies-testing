# Test resources for policies/30/6-2-8-pgaudit-enabled.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_pgaudit_enabled_off   -> violates the policy ('cloudsql.enable_pgaudit' = 'off')
# pass_pgaudit_enabled_on    -> complies with the policy ('cloudsql.enable_pgaudit' = 'ON', case-insensitive)
# fail_pgaudit_enabled_unset -> violates the policy (flag unset; the default is 'off')

resource "google_sql_database_instance" "fail_pgaudit_enabled_off" {
  name                = "fail-pgaudit-enabled-off"
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
      value = "off"
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

resource "google_sql_database_instance" "pass_pgaudit_enabled_on" {
  name                = "pass-pgaudit-enabled-on"
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
      value = "ON"
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

resource "google_sql_database_instance" "fail_pgaudit_enabled_unset" {
  name                = "fail-pgaudit-enabled-unset"
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
