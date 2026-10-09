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

resource "google_project" "auto_create_network_false_passes" {
  attrs = {
    name                 = "My Project"
    project_id           = "project-c"
    org_id               = "1234567"
    auto_create_network  = false
  }
}

resource "google_project" "auto_create_network_true_fails" {
  expect_failure = true
  attrs = {
    name                = "My Project"
    project_id          = "project-d"
    org_id              = "1234567"
    auto_create_network = true
  }
}

resource "google_project" "auto_create_network_omitted_fails" {
  expect_failure = true
  attrs = {
    name       = "My Project"
    project_id = "project-e"
    org_id     = "1234567"
  }
}
