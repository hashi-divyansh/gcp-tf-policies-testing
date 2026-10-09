# Test resources for policies/30/6-1-3-local-infile-off.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_local_infile_off_on    -> violates the policy ('local_infile' = 'on')
# pass_local_infile_off_off   -> complies with the policy ('local_infile' = 'OFF', case-insensitive)
# fail_local_infile_off_unset -> violates the policy (flag unset; the default is 'on')

resource "google_sql_database_instance" "fail_local_infile_off_on" {
  name                = "fail-local-infile-off-on"
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
      value = "on"
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

resource "google_sql_database_instance" "pass_local_infile_off_off" {
  name                = "pass-local-infile-off-off"
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
      value = "OFF"
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

resource "google_sql_database_instance" "fail_local_infile_off_unset" {
  name                = "fail-local-infile-off-unset"
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
