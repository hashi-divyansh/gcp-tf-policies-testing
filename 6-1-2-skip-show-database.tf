# Test resources for policies/30/6-1-2-skip-show-database.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_skip_show_database_off   -> violates the policy ('skip_show_database' = 'off')
# pass_skip_show_database_on    -> complies with the policy ('skip_show_database' = 'ON', case-insensitive)
# fail_skip_show_database_unset -> violates the policy (flag unset; the default is 'off')

resource "google_sql_database_instance" "fail_skip_show_database_off" {
  name                = "fail-skip-show-database-off"
  database_version    = "MYSQL_8_0"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "skip_show_database"
      value = "off"
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

resource "google_sql_database_instance" "pass_skip_show_database_on" {
  name                = "pass-skip-show-database-on"
  database_version    = "MYSQL_8_0"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "skip_show_database"
      value = "ON"
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

resource "google_sql_database_instance" "fail_skip_show_database_unset" {
  name                = "fail-skip-show-database-unset"
  database_version    = "MYSQL_8_0"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
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
