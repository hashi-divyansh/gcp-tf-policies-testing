# Copyright IBM Corp. 2026

policytest {
  targets = ["6-3-3-user-connections.policy.hcl"]
}

resource "google_sql_database_instance" "pass_0" {
  attrs = {
    name             = "pass-0"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "user connections", value = "0" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_100" {
  expect_failure = true
  attrs = {
    name             = "fail-100"
    database_version = "SQLSERVER_2019_STANDARD"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "user connections", value = "100" },
      ]
    }]
  }
}

# Unset flag: The default ('0', non-limiting) is compliant.
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
        { name = "user connections", value = "100" },
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
        { name = "user connections", value = "100" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_100" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-100"
    database_version     = "SQLSERVER_2019_STANDARD"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "user connections", value = "100" },
      ]
    }]
  }
}
