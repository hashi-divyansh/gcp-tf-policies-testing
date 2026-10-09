# Copyright IBM Corp. 2026

policytest {
  targets = ["6-5-sql-no-open-networks.policy.hcl"]
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
