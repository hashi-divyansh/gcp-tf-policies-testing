# Copyright IBM Corp. 2026

policytest {
  targets = ["6-1-3-local-infile-off.policy.hcl"]
}

resource "google_sql_database_instance" "pass_off" {
  attrs = {
    name             = "pass-off"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "local_infile", value = "off" },
      ]
    }]
  }
}

# Flag values are matched case-insensitively.
resource "google_sql_database_instance" "pass_uppercase_off" {
  attrs = {
    name             = "pass-uppercase-off"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "local_infile", value = "OFF" },
      ]
    }]
  }
}

resource "google_sql_database_instance" "fail_on" {
  expect_failure = true
  attrs = {
    name             = "fail-on"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "local_infile", value = "on" },
      ]
    }]
  }
}

# Unset flag: The default is 'on'.
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
        { name = "local_infile", value = "on" },
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
        { name = "local_infile", value = "off" },
        { name = "local_infile", value = "on" },
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
        { name = "local_infile", value = "on" },
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

resource "google_sql_database_instance" "pass_read_replica_off" {
  attrs = {
    name                 = "pass-read-replica-off"
    database_version     = "MYSQL_8_0"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    instance_type        = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      database_flags = [
        { name = "local_infile", value = "off" },
      ]
    }]
  }
}

# A Database Migration Service connection profile creates its Cloud SQL destination instance with cloudsql.settings.database_flags.
resource "google_database_migration_service_connection_profile" "pass_dms_off" {
  attrs = {
    connection_profile_id = "pass-dms-off"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          local_infile = "off"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_uppercase_off" {
  attrs = {
    connection_profile_id = "pass-dms-uppercase-off"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          local_infile = "OFF"
        }
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_on" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-on"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/my-project/locations/us-central1/connectionProfiles/source-profile"
        database_flags = {
          local_infile = "on"
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
          local_infile = "on"
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
          local_infile = "on"
        }
      }]
    }]
  }
}
