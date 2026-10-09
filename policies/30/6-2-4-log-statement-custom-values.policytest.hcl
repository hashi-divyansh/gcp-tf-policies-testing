# Copyright IBM Corp. 2026

policytest {
  targets = ["6-2-4-log-statement.policy.hcl"]
}

# Exercises the log-statement-allowed-values input with an organization-specific list.
inputs {
  log-statement-allowed-values = ["MOD", "none"]
}

resource "google_sql_database_instance" "pass_mod_when_allowed" {
  attrs = {
    name             = "pass-mod-when-allowed"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "mod" },
      ]
    }]
  }
}

# An unset flag means 'none', which this organization allows.
resource "google_sql_database_instance" "pass_flag_absent_when_none_allowed" {
  attrs = {
    name             = "pass-flag-absent-when-none-allowed"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "fail_ddl_when_not_allowed" {
  expect_failure = true
  attrs = {
    name             = "fail-ddl-when-not-allowed"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "ddl" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_all_when_not_allowed" {
  expect_failure = true
  attrs = {
    name             = "fail-all-when-not-allowed"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "all" },
      ]
    }]
  }
}

# The allowed-values input also applies to Database Migration Service destinations.
resource "google_database_migration_service_connection_profile" "pass_dms_flag_absent_when_none_allowed" {
  attrs = {
    connection_profile_id = "pass-dms-flag-absent-when-none-allowed"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_ddl_when_not_allowed" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-ddl-when-not-allowed"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_statement = "ddl"
        }
      }]
    }]
  }
}
