# Test resources for policies/30/6-3-3-user-connections.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# Every instance is otherwise compliant with all 6.x controls (baseline flags,
# private IP only, ENCRYPTED_ONLY SSL, backups on), so each fail_* resource
# violates only this control. Cloud SQL instances take minutes to create.
#
# fail_user_connections_100   -> violates the policy ('user connections' = '100')
# pass_user_connections_0     -> complies with the policy ('user connections' = '0', case-insensitive)
# pass_user_connections_unset -> complies with the policy (flag unset; the default ('0', non-limiting) is compliant)

resource "google_sql_database_instance" "fail_user_connections_100" {
  name                = "fail-user-connections-100"
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
      name  = "user connections"
      value = "100"
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

resource "google_sql_database_instance" "pass_user_connections_0" {
  name                = "pass-user-connections-0"
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
      name  = "user connections"
      value = "0"
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

resource "google_sql_database_instance" "pass_user_connections_unset" {
  name                = "pass-user-connections-unset"
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
