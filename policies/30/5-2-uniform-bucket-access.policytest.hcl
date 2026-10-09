# Copyright IBM Corp. 2026

policytest {
  targets = ["5-2-uniform-bucket-access.policy.hcl"]
}

resource "google_storage_bucket" "pass_ubla_enabled" {
  attrs = {
    name                        = "pass-ubla-enabled"
    location                    = "US"
    uniform_bucket_level_access = true
  }
}

resource "google_storage_bucket" "fail_ubla_disabled" {
  expect_failure = true
  attrs = {
    name                        = "fail-ubla-disabled"
    location                    = "US"
    uniform_bucket_level_access = false
  }
}

# Uniform bucket-level access is disabled by default.
resource "google_storage_bucket" "fail_ubla_unset" {
  expect_failure = true
  attrs = {
    name     = "fail-ubla-unset"
    location = "US"
  }
}

# Public access prevention does not replace uniform bucket-level access.
resource "google_storage_bucket" "fail_ubla_disabled_with_pap_enforced" {
  expect_failure = true
  attrs = {
    name                        = "fail-ubla-disabled-pap"
    location                    = "US"
    uniform_bucket_level_access = false
    public_access_prevention    = "enforced"
  }
}
