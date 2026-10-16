# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudsql-no-open-authorized-networks.policy.hcl"]
}

resource "google_sql_database_instance" "pass_trusted_network_only" {
  attrs = {
    name             = "pass-trusted-network-only"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "203.0.113.0/24" },
        ]
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_no_authorized_networks" {
  attrs = {
    name             = "pass-no-authorized-networks"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled = false
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_no_ip_configuration" {
  attrs = {
    name             = "pass-no-ip-configuration"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

resource "google_sql_database_instance" "fail_open_to_internet" {
  expect_failure = true
  attrs = {
    name             = "fail-open-to-internet"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "0.0.0.0/0" },
        ]
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_open_network_among_trusted" {
  expect_failure = true
  attrs = {
    name             = "fail-open-network-among-trusted"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "203.0.113.0/24" },
          { name = "n1", value = "0.0.0.0/0" },
        ]
      }]
    }]
  }
}

# The authorized network value accepts IPv6 CIDRs; ::/0 allows any address.
resource "google_sql_database_instance" "fail_ipv6_any_address" {
  expect_failure = true
  attrs = {
    name             = "fail-ipv6-any-address"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "::/0" },
        ]
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_ipv6_specific_range" {
  attrs = {
    name             = "pass-ipv6-specific-range"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "2001:db8::/32" },
        ]
      }]
    }]
  }
}

# A bare address without a prefix length is a single host, not an open range.
resource "google_sql_database_instance" "pass_single_host_address" {
  attrs = {
    name             = "pass-single-host-address"
    database_version = "MYSQL_8_0"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        authorized_networks = [
          { name = "n0", value = "203.0.113.10" },
        ]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_trusted_network" {
  attrs = {
    connection_profile_id = "pass-dms-trusted-network"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ authorized_networks = [{ value = "203.0.113.0/24" }] }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_open_network_among_trusted" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-open-network-among-trusted"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config = [{
          enable_ipv4 = true
          authorized_networks = [
            { value = "203.0.113.0/24" },
            { value = "0.0.0.0/0" },
          ]
        }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "fail_dms_ipv6_any_address" {
  expect_failure = true
  attrs = {
    connection_profile_id = "fail-dms-ipv6-any-address"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ authorized_networks = [{ value = "::/0" }] }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_no_ip_config" {
  attrs = {
    connection_profile_id = "pass-dms-no-ip-config"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_networks_omitted" {
  attrs = {
    connection_profile_id = "pass-dms-networks-omitted"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ require_ssl = true }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_empty_networks" {
  attrs = {
    connection_profile_id = "pass-dms-empty-networks"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "POSTGRES_15"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ authorized_networks = [] }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_dms_null_networks" {
  attrs = {
    connection_profile_id = "pass-dms-null-networks"
    location              = "us-central1"
    cloudsql = [{
      settings = [{
        database_version = "MYSQL_8_0"
        source_id        = "projects/example-project/locations/us-central1/connectionProfiles/source"
        ip_config        = [{ authorized_networks = null }]
      }]
    }]
  }
}

resource "google_database_migration_service_connection_profile" "pass_postgres_source_out_of_scope" {
  attrs = {
    connection_profile_id = "pass-postgres-source-out-of-scope"
    location              = "us-central1"
    postgresql            = [{ host = "192.0.2.10", port = 5432, username = "migration" }]
  }
}
