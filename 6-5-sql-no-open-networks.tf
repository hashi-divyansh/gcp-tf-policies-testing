# Test resources for policies/30/6-5-sql-no-open-networks.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
# Authorized networks need a public IP, so these instances also fail 6.7.
#
# fail_sql_authorized_any         -> violates the policy (authorized network 0.0.0.0/0)
# pass_sql_authorized_office      -> complies with the policy (specific CIDR only)
# pass_sql_no_authorized_networks -> complies with the policy (no authorized networks)

resource "google_sql_database_instance" "fail_sql_authorized_any" {
  name                = "fail-sql-authorized-any"
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
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
      authorized_networks {
        name  = "office"
        value = "203.0.113.0/24"
      }
      authorized_networks {
        name  = "anywhere"
        value = "0.0.0.0/0"
      }
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_authorized_office" {
  name                = "pass-sql-authorized-office"
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
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
      authorized_networks {
        name  = "office"
        value = "203.0.113.0/24"
      }
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_no_authorized_networks" {
  name                = "pass-sql-no-authorized-networks"
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
