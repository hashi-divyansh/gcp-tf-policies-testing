# Copyright IBM Corp. 2026

policytest {
  targets = ["3-10-vpc-flow-logs.policy.hcl"]
}

resource "google_compute_subnetwork" "pass_compliant_flow_logs" {
  attrs = {
    name          = "compliant-subnetwork"
    ip_cidr_range = "10.0.0.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
    log_config = {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 1
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "pass_regional_managed_proxy_exception" {
  attrs = {
    name          = "regional-proxy-subnetwork"
    ip_cidr_range = "10.0.1.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "REGIONAL_MANAGED_PROXY"
  }
}

resource "google_compute_subnetwork" "pass_global_managed_proxy_exception" {
  attrs = {
    name          = "global-proxy-subnetwork"
    ip_cidr_range = "10.0.2.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "GLOBAL_MANAGED_PROXY"
  }
}

resource "google_compute_subnetwork" "fail_missing_log_config" {
  expect_failure = true
  attrs = {
    name          = "missing-log-config-subnetwork"
    ip_cidr_range = "10.0.3.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
  }
}

resource "google_compute_subnetwork" "fail_null_log_config" {
  expect_failure = true
  attrs = {
    name          = "null-log-config-subnetwork"
    ip_cidr_range = "10.0.4.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
    log_config    = null
  }
}

resource "google_compute_subnetwork" "fail_wrong_aggregation_interval" {
  expect_failure = true
  attrs = {
    name          = "wrong-interval-subnetwork"
    ip_cidr_range = "10.0.5.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
    log_config = {
      aggregation_interval = "INTERVAL_30_SEC"
      flow_sampling        = 1
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "fail_wrong_flow_sampling" {
  expect_failure = true
  attrs = {
    name          = "wrong-sampling-subnetwork"
    ip_cidr_range = "10.0.6.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
    log_config = {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "fail_wrong_metadata" {
  expect_failure = true
  attrs = {
    name          = "wrong-metadata-subnetwork"
    ip_cidr_range = "10.0.7.0/24"
    region        = "us-central1"
    network       = "validation-network"
    purpose       = "PRIVATE"
    log_config = {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 1
      metadata             = "EXCLUDE_ALL_METADATA"
    }
  }
}
