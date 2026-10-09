# Test resources for policies/30/6-3-7-contained-db-auth-off.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_contained_db_auth_off_on    -> violates the policy ('contained database authentication' = 'on')
# pass_contained_db_auth_off_off   -> complies with the policy ('contained database authentication' = 'OFF', case-insensitive)
# pass_contained_db_auth_off_unset -> complies with the policy (flag unset; the default ('off') is compliant)

resource "google_sql_database_instance" "fail_contained_db_auth_off_on" {
  name                = "fail-contained-db-auth-off-on"
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
      name  = "contained database authentication"
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

resource "google_sql_database_instance" "pass_contained_db_auth_off_off" {
  name                = "pass-contained-db-auth-off-off"
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
      name  = "contained database authentication"
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

resource "google_sql_database_instance" "pass_contained_db_auth_off_unset" {
  name                = "pass-contained-db-auth-off-unset"
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
