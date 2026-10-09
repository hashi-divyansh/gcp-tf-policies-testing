# Test resources for policies/30/6-7-sql-no-public-ip.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_sql_public_ip_only    -> violates the policy (ipv4_enabled = true, no private network)
# fail_sql_public_and_private -> violates the policy (ipv4_enabled = true alongside private IP)
# pass_sql_private_ip_only   -> complies with the policy (ipv4_enabled = false + private_network)
#
# instance_type is set explicitly: master_instance_name is unknown at plan for new
# primaries, so the policy uses a known instance_type to rule out read replicas.

resource "google_sql_database_instance" "fail_sql_public_ip_only" {
  name                = "fail-sql-public-ip-only"
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
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "fail_sql_public_and_private" {
  name                = "fail-sql-public-and-private"
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
      ipv4_enabled    = true
      private_network = "projects/${var.project_id}/global/networks/policy-test-vpc"
      ssl_mode        = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_private_ip_only" {
  name                = "pass-sql-private-ip-only"
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
