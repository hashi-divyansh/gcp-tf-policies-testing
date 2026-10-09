# Copyright IBM Corp. 2026

policytest {
  targets = ["6-1-2-skip-show-database.policy.hcl"]
}

resource "google_sql_database_instance" "pass_on" {
  attrs = {
    name             = "pass-on"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "on" },
      ]
    }]
  }
}

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_on" {
  attrs = {
    name             = "pass-uppercase-on"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "ON" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_off" {
  expect_failure = true
  attrs = {
    name             = "fail-off"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "off" },
      ]
    }]
  }
}

# Unset flag: The default is 'off'.
resource "google_sql_database_instance" "fail_flag_absent" {
  expect_failure = true
  attrs = {
    name             = "fail-flag-absent"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "general_log", value = "off" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_no_database_flags" {
  expect_failure = true
  attrs = {
    name             = "fail-no-database-flags"
    database_version = "MYSQL_8_0"
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
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "general_log", value = "off" },
        { name = "skip_show_database", value = "off" },
      ]
    }]
  }
}

# Every occurrence of the flag must be compliant.
resource "google_sql_database_instance" "fail_duplicate_with_one_non_compliant" {
  expect_failure = true
  attrs = {
    name             = "fail-duplicate-with-one-non-compliant"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "on" },
        { name = "skip_show_database", value = "off" },
      ]
    }]
  }
}

# Only MySQL instances are in scope.
resource "google_sql_database_instance" "pass_other_engine_out_of_scope" {
  attrs = {
    name             = "pass-other-engine-out-of-scope"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "off" },
      ]
    }]
  }
}

# Read replicas are evaluated: database flags are set per instance and are not inherited from the primary.
resource "google_sql_database_instance" "fail_read_replica_flag_absent" {
  expect_failure = true
  attrs = {
    name                 = "fail-read-replica-flag-absent"
    database_version     = "MYSQL_8_0"
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
    database_version     = "MYSQL_8_0"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "skip_show_database", value = "on" },
      ]
    }]
  }
}

# A Database Migration Service connection profile creates its Cloud SQL destination instance with cloudsql.settings.database_flags.
resource "google_database_migration_service_connection_profile" "pass_dms_on" {
  attrs = {
    connection_profile_id = "pass-dms-on"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          skip_show_database = "on"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_uppercase_on" {
  attrs = {
    connection_profile_id = "pass-dms-uppercase-on"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          skip_show_database = "ON"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_off" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-off"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          skip_show_database = "off"
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
        database_version = "MYSQL_8_0"
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
        database_version = "POSTGRES_15"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          skip_show_database = "off"
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
          skip_show_database = "off"
        }
      }]
    }]
  }
}
