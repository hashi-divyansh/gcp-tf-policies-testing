# Test resources for policies/30/6-3-6-trace-flag-3625.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_trace_flag_3625_off   -> violates the policy ('3625' = 'off')
# pass_trace_flag_3625_on    -> complies with the policy ('3625' = 'ON', case-insensitive)
# fail_trace_flag_3625_unset -> violates the policy (flag unset; the default is 'off')

resource "google_sql_database_instance" "fail_trace_flag_3625_off" {
  name                = "fail-trace-flag-3625-off"
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

resource "google_sql_database_instance" "pass_trace_flag_3625_on" {
  name                = "pass-trace-flag-3625-on"
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
      value = "ON"
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

resource "google_sql_database_instance" "fail_trace_flag_3625_unset" {
  name                = "fail-trace-flag-3625-unset"
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
