# Copyright IBM Corp. 2026

policytest {
  targets = ["3-2-no-legacy-net.policy.hcl"]
}

resource "google_compute_network" "pass_auto_subnet_mode" {
  attrs = {
    name                    = "auto-network"
    auto_create_subnetworks = true
  }
}

resource "google_compute_network" "pass_custom_subnet_mode" {
  attrs = {
    name                    = "custom-network"
    auto_create_subnetworks = false
    gateway_ipv4            = null
  }
}

# The optional mode attribute is omitted to exercise missing-attribute safety;
# the legacy gateway still makes this older managed network non-compliant.
resource "google_compute_network" "fail_legacy_network" {
  expect_failure = true
  attrs = {
    name         = "legacy-network"
    gateway_ipv4 = "10.240.0.1"
  }
}
