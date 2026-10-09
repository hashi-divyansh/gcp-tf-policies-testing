# Copyright IBM Corp. 2026

policytest {
  targets = ["6-7-sql-no-public-ip.policy.hcl"]
}

resource "google_sql_database_instance" "pass_private_ip_only" {
  attrs = {
    name             = "pass-private-ip-only"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled    = false
        private_network = "projects/example-project/global/networks/private-vpc"
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_public_ip_enabled" {
  expect_failure = true
  attrs = {
    name             = "fail-public-ip-enabled"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled    = true
        private_network = "projects/example-project/global/networks/private-vpc"
      }]
    }]
  }
}

# ipv4_enabled defaults to true (public IP) when unset.
resource "google_sql_database_instance" "fail_ipv4_enabled_unset" {
  expect_failure = true
  attrs = {
    name             = "fail-ipv4-enabled-unset"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        private_network = "projects/example-project/global/networks/private-vpc"
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_no_ip_configuration" {
  expect_failure = true
  attrs = {
    name             = "fail-no-ip-configuration"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    settings = [{
      tier = "db-custom-2-7680"
    }]
  }
}

# CIS requires a PRIVATE IP address, so private_network must be set.
resource "google_sql_database_instance" "fail_no_public_and_no_private_ip" {
  expect_failure = true
  attrs = {
    name             = "fail-no-public-and-no-private-ip"
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

# Read replicas inherit IP settings from the primary and are excluded.
resource "google_sql_database_instance" "pass_read_replica_out_of_scope" {
  attrs = {
    name                 = "pass-read-replica-out-of-scope"
    database_version     = "POSTGRES_15"
    region               = "us-central1"
    master_instance_name = "primary-instance"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled = true
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_read_replica_instance_type_out_of_scope" {
  attrs = {
    name             = "pass-read-replica-instance-type-out-of-scope"
    database_version = "POSTGRES_15"
    region           = "us-central1"
    instance_type    = "READ_REPLICA_INSTANCE"
    settings = [{
      tier = "db-custom-2-7680"
      ip_configuration = [{
        ipv4_enabled = true
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_primary_instance_type_public_ip" {
  expect_failure = true
  attrs = {
    name             = "primary-public"
    database_version = "POSTGRES_15"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled = true
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_primary_instance_type_private_ip" {
  attrs = {
    name             = "primary-private"
    database_version = "POSTGRES_15"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled    = false
        private_network = "projects/example-project/global/networks/private-vpc"
      }]
    }]
  }
}

resource "google_sql_database_instance" "pass_read_pool_out_of_scope" {
  attrs = {
    name             = "read-pool"
    database_version = "POSTGRES_15"
    instance_type    = "READ_POOL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
    }]
  }
}

resource "google_sql_database_instance" "pass_psc_only" {
  attrs = {
    name             = "psc-only"
    database_version = "MYSQL_8_0"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled = false
        psc_config = [{
          psc_enabled               = true
          allowed_consumer_projects = ["example-project"]
        }]
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_psc_with_public_ip" {
  expect_failure = true
  attrs = {
    name             = "psc-public"
    database_version = "MYSQL_8_0"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled = true
        psc_config = [{
          psc_enabled = true
        }]
      }]
    }]
  }
}

resource "google_sql_database_instance" "fail_psc_disabled_no_private_network" {
  expect_failure = true
  attrs = {
    name             = "psc-disabled"
    database_version = "MYSQL_8_0"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled = false
        psc_config = [{
          psc_enabled = false
        }]
      }]
    }]
  }
}

# PSC can be combined with private services access (private_network).
resource "google_sql_database_instance" "pass_psc_with_private_network" {
  attrs = {
    name             = "psc-and-psa"
    database_version = "POSTGRES_15"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled    = false
        private_network = "projects/example-project/global/networks/private-vpc"
        psc_config = [{
          psc_enabled               = true
          allowed_consumer_projects = ["example-project"]
        }]
      }]
    }]
  }
}

# A psc_config block without psc_enabled = true does not provide private connectivity.
resource "google_sql_database_instance" "fail_psc_enabled_unset_no_private_network" {
  expect_failure = true
  attrs = {
    name             = "psc-enabled-unset"
    database_version = "MYSQL_8_0"
    instance_type    = "CLOUD_SQL_INSTANCE"
    settings = [{
      tier = "db-f1-micro"
      ip_configuration = [{
        ipv4_enabled = false
        psc_config = [{
          allowed_consumer_projects = ["example-project"]
        }]
      }]
    }]
  }
}
