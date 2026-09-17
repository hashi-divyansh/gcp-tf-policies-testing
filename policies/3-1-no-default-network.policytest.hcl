# Copyright IBM Corp. 2026

policytest {
  targets = ["3-1-no-default-network.policy.hcl"]
}

resource "google_compute_network" "custom_network_passes" {
  attrs = {
    name    = "application-network"
    project = "project-a"
  }
}

resource "google_compute_network" "default_network_fails" {
  expect_failure = true
  attrs = {
    name    = "default"
    project = "project-b"
  }
}
