# Test resources for policies/3-10-vpc-flow-logs.policy.hcl
#
# fail_flow_logs_missing -> violates the policy (no log_config block)
# pass_flow_logs_compliant -> complies with the policy (log_config set per CIS 3.10 requirements)

resource "google_compute_subnetwork" "fail_flow_logs_missing" {
  name          = "fail-flow-logs-missing"
  network       = google_compute_network.test_3_6_vpc.name
  ip_cidr_range = "10.20.0.0/24"
  region        = "us-central1"
}

resource "google_compute_subnetwork" "pass_flow_logs_compliant" {
  name          = "pass-flow-logs-compliant"
  network       = google_compute_network.test_3_6_vpc.name
  ip_cidr_range = "10.20.1.0/24"
  region        = "us-central1"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
