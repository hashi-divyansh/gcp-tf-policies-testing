# Test resources for policies/30/6-3-2-cross-db-chaining-off.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_cross_db_chaining_off_on    -> violates the policy ('cross db ownership chaining' = 'on')
# pass_cross_db_chaining_off_off   -> complies with the policy ('cross db ownership chaining' = 'OFF', case-insensitive)
# pass_cross_db_chaining_off_unset -> complies with the policy (flag unset; the flag is deprecated; an unset flag is compliant)

resource "google_sql_database_instance" "fail_cross_db_chaining_off_on" {
  name                = "fail-cross-db-chaining-off-on"
  database_version    = "SQLSERVER_2019_STANDARD"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false
  root_password       = random_password.sqlserver_root.result

  settings {
    tier = "db-custom-2-7680"
    database_flags {
      name  = "remote access"
      value = "off"
    }
    database_flags {
      name  = "3625"
      value = "on"
    }
    database_flags {
      name  = "cross db ownership chaining"
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

resource "google_sql_database_instance" "pass_cross_db_chaining_off_off" {
  name                = "pass-cross-db-chaining-off-off"
  database_version    = "SQLSERVER_2019_STANDARD"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false
  root_password       = random_password.sqlserver_root.result

  settings {
    tier = "db-custom-2-7680"
    database_flags {
      name  = "remote access"
      value = "off"
    }
    database_flags {
      name  = "3625"
      value = "on"
    }
    database_flags {
      name  = "cross db ownership chaining"
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

resource "google_sql_database_instance" "pass_cross_db_chaining_off_unset" {
  name                = "pass-cross-db-chaining-off-unset"
  database_version    = "SQLSERVER_2019_STANDARD"
  instance_type       = "CLOUD_SQL_INSTANCE"
  region              = "us-central1"
  deletion_protection = false
  root_password       = random_password.sqlserver_root.result

  settings {
    tier = "db-custom-2-7680"
    database_flags {
      name  = "remote access"
      value = "off"
    }
    database_flags {
      name  = "3625"
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
