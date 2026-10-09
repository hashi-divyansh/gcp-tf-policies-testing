# Test resources for policies/30/6-8-sql-backups.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_sql_backups_disabled -> violates the policy (backup_configuration.enabled = false)
# pass_sql_backups_enabled  -> complies with the policy (backup_configuration.enabled = true)
#
# backup_configuration is always set: it is computed (unknown at plan) when omitted.

resource "google_sql_database_instance" "fail_sql_backups_disabled" {
  name                = "fail-sql-backups-disabled"
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
      ssl_mode        = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled = false
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_sql_database_instance" "pass_sql_backups_enabled" {
  name                = "pass-sql-backups-enabled"
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
      ssl_mode        = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled = true
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}
