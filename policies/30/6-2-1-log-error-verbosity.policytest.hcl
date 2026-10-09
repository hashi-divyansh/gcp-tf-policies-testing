# Copyright IBM Corp. 2026

policytest {
  targets = ["6-2-1-log-error-verbosity.policy.hcl"]
}

resource "google_sql_database_instance" "pass_default" {
  attrs = {
    name             = "pass-default"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_error_verbosity", value = "default" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "pass_terse" {
  attrs = {
    name             = "pass-terse"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_error_verbosity", value = "terse" },
      ]
    }]
  }
}

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_default" {
  attrs = {
    name             = "pass-uppercase-default"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_error_verbosity", value = "DEFAULT" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_verbose" {
  expect_failure = true
  attrs = {
    name             = "fail-verbose"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_error_verbosity", value = "verbose" },
      ]
    }]
  }
}

# Unset flag: The default ('default') is compliant.
resource "google_sql_database_instance" "pass_flag_absent" {
  attrs = {
    name             = "pass-flag-absent"
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

resource "google_sql_database_instance" "pass_no_database_flags" {
  attrs = {
    name             = "pass-no-database-flags"
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
        { name = "log_error_verbosity", value = "verbose" },
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
        { name = "log_error_verbosity", value = "verbose" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_verbose" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-verbose"
    database_version     = "POSTGRES_15"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "log_error_verbosity", value = "verbose" },
      ]
    }]
  }
}

# A Database Migration Service connection profile creates its Cloud SQL destination instance with cloudsql.settings.database_flags.
resource "google_database_migration_service_connection_profile" "pass_dms_terse" {
  attrs = {
    connection_profile_id = "pass-dms-terse"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_error_verbosity = "terse"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_uppercase_terse" {
  attrs = {
    connection_profile_id = "pass-dms-uppercase-terse"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_error_verbosity = "TERSE"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_verbose" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-verbose"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          log_error_verbosity = "verbose"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_flag_absent" {
  attrs = {
    connection_profile_id = "pass-dms-flag-absent"
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
          log_error_verbosity = "verbose"
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
          log_error_verbosity = "verbose"
        }
      }]
    }]
  }
}
