# Copyright IBM Corp. 2026

policytest {
  targets = ["6-3-1-external-scripts-off.policy.hcl"]
}

resource "google_sql_database_instance" "pass_off" {
  attrs = {
    name             = "pass-off"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "external scripts enabled", value = "off" },
      ]
    }]
  }
}

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_off" {
  attrs = {
    name             = "pass-uppercase-off"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "external scripts enabled", value = "OFF" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_on" {
  expect_failure = true
  attrs = {
    name             = "fail-on"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "external scripts enabled", value = "on" },
      ]
    }]
  }
}

# Unset flag: The default ('off') is compliant.
resource "google_sql_database_instance" "pass_flag_absent" {
  attrs = {
    name             = "pass-flag-absent"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "max degree of parallelism", value = "0" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "pass_no_database_flags" {
  attrs = {
    name             = "pass-no-database-flags"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "fail_non_compliant_among_other_flags" {
  expect_failure = true
  attrs = {
    name             = "fail-non-compliant-among-other-flags"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "max degree of parallelism", value = "0" },
        { name = "external scripts enabled", value = "on" },
      ]
    }]
  }
}

# Only SQL Server instances are in scope.
resource "google_sql_database_instance" "pass_other_engine_out_of_scope" {
  attrs = {
    name             = "pass-other-engine-out-of-scope"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "external scripts enabled", value = "on" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_on" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-on"
    database_version     = "SQLSERVER_2019_STANDARD"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "external scripts enabled", value = "on" },
      ]
    }]
  }
}
