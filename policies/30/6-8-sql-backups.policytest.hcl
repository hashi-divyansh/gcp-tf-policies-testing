# Copyright IBM Corp. 2026

policytest {
  targets = ["6-8-sql-backups.policy.hcl"]
}

resource "google_sql_database_instance" "pass_backups_enabled" {
  attrs = {
    name             = "pass-backups-enabled"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      backup_configuration = [{
        enabled    = true
        start_time = "03:00"
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_backups_disabled" {
  expect_failure = true
  attrs = {
    name             = "fail-backups-disabled"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      backup_configuration = [{
        enabled = false
      }]
    }]
  }
}

# Automated backups are not configured by default.
resource "google_sql_database_instance" "fail_no_backup_configuration" {
  expect_failure = true
  attrs = {
    name             = "fail-no-backup-configuration"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "fail_backup_enabled_unset" {
  expect_failure = true
  attrs = {
    name             = "fail-backup-enabled-unset"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      backup_configuration = [{
        start_time = "03:00"
      }]
    }]
  }
}

# GCP does not provide automated backups for read replicas.
resource "google_sql_database_instance" "pass_read_replica_out_of_scope" {
  attrs = {
    name                 = "pass-read-replica-out-of-scope"
    database_version     = "POSTGRES_15"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    settings = [{
      tier = "db-custom-2-7680"
      backup_configuration = [{
        enabled = false
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_read_replica_instance_type_out_of_scope" {
  attrs = {
    name             = "pass-read-replica-instance-type-out-of-scope"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    instance_type    = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "fail_primary_instance_type_backups_disabled" {
  expect_failure = true
  attrs = {
    name             = "primary-no-backups"
    database_version = "MYSQL_8_0"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      backup_configuration = [{
        enabled = false
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_read_pool_out_of_scope" {
  attrs = {
    name             = "read-pool"
    database_version = "POSTGRES_15"
    instance_type    = "READ_POOL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
    }]
  }
}
