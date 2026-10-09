# Copyright IBM Corp. 2026

policytest {
  targets = ["6-2-4-log-statement.policy.hcl"]
}

resource "google_sql_database_instance" "pass_ddl" {
  attrs = {
    name             = "pass-ddl"
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

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_ddl" {
  attrs = {
    name             = "pass-uppercase-ddl"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "DDL" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_mod_not_in_default_allowed_values" {
  expect_failure = true
  attrs = {
    name             = "fail-mod-not-in-default-allowed-values"
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

resource "google_sql_database_instance" "fail_all" {
  expect_failure = true
  attrs = {
    name             = "fail-all"
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

resource "google_sql_database_instance" "fail_none" {
  expect_failure = true
  attrs = {
    name             = "fail-none"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "none" },
      ]
    }]
  }
}

# Unset flag: the default ('none') is non-compliant unless 'none' is allowed.
resource "google_sql_database_instance" "fail_flag_absent" {
  expect_failure = true
  attrs = {
    name             = "fail-flag-absent"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_checkpoints", value = "on" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_no_database_flags" {
  expect_failure = true
  attrs = {
    name             = "fail-no-database-flags"
    database_version = "POSTGRES_15"
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
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_checkpoints", value = "on" },
        { name = "log_statement", value = "all" },
      ]
    }]
  }
}

# Only PostgreSQL instances are in scope.
resource "google_sql_database_instance" "pass_other_engine_out_of_scope" {
  attrs = {
    name             = "pass-other-engine-out-of-scope"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "all" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_flag_absent" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-flag-absent"
    database_version     = "POSTGRES_15"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "pass_read_replica_ddl" {
  attrs = {
    name                 = "pass-read-replica-ddl"
    database_version     = "POSTGRES_15"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_statement", value = "ddl" },
      ]
    }]
  }
}

# A Database Migration Service connection profile creates its Cloud SQL destination instance with cloudsql.settings.database_flags.
resource "google_database_migration_service_connection_profile" "pass_dms_ddl" {
  attrs = {
    connection_profile_id = "pass-dms-ddl"
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

resource "google_database_migration_service_connection_profile" "pass_dms_uppercase_ddl" {
  attrs = {
    connection_profile_id = "pass-dms-uppercase-ddl"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_statement = "DDL"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_mod" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-mod"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_statement = "mod"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_flag_absent" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-flag-absent"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
      }]
    }]
  }
}

# Only destinations of this engine are in scope.
resource "google_database_migration_service_connection_profile" "pass_dms_other_engine_out_of_scope" {
  attrs = {
    connection_profile_id = "pass-dms-other-engine-out-of-scope"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_statement = "mod"
        }
      }]
    }]
  }
}

# Without cloudsql.settings.database_version the destination engine is unknown, so the profile is not evaluated.
resource "google_database_migration_service_connection_profile" "pass_dms_no_database_version_not_evaluated" {
  attrs = {
    connection_profile_id = "pass-dms-no-database-version-not-evaluated"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        source_id = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_statement = "mod"
        }
      }]
    }]
  }
}
