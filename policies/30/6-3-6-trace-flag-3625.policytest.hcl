# Copyright IBM Corp. 2026

policytest {
  targets = ["6-3-6-trace-flag-3625.policy.hcl"]
}

resource "google_sql_database_instance" "pass_on" {
  attrs = {
    name             = "pass-on"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "3625", value = "on" },
      ]
    }]
  }
}

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_on" {
  attrs = {
    name             = "pass-uppercase-on"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "3625", value = "ON" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_off" {
  expect_failure = true
  attrs = {
    name             = "fail-off"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "3625", value = "off" },
      ]
    }]
  }
}

# Unset flag: The default is 'off'.
resource "google_sql_database_instance" "fail_flag_absent" {
  expect_failure = true
  attrs = {
    name             = "fail-flag-absent"
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

resource "google_sql_database_instance" "fail_no_database_flags" {
  expect_failure = true
  attrs = {
    name             = "fail-no-database-flags"
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
        { name = "3625", value = "off" },
      ]
    }]
  }
}

# Every occurrence of the flag must be compliant.
resource "google_sql_database_instance" "fail_duplicate_with_one_non_compliant" {
  expect_failure = true
  attrs = {
    name             = "fail-duplicate-with-one-non-compliant"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "3625", value = "on" },
        { name = "3625", value = "off" },
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
        { name = "3625", value = "off" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_flag_absent" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-flag-absent"
    database_version     = "SQLSERVER_2019_STANDARD"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "pass_read_replica_on" {
  attrs = {
    name                 = "pass-read-replica-on"
    database_version     = "SQLSERVER_2019_STANDARD"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "3625", value = "on" },
      ]
    }]
  }
}
