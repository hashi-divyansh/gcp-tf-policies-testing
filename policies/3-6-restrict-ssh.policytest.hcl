# Copyright IBM Corp. 2026

policytest {
  targets = ["3-6-restrict-ssh.policy.hcl"]
}

resource "google_compute_firewall" "pass_trusted_source_tcp_22" {
  attrs = {
    name          = "trusted-source-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["203.0.113.10/32"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_tcp_22" {
  expect_failure = true
  attrs = {
    name          = "internet-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_all_ports_omitted" {
  expect_failure = true
  attrs = {
    name          = "internet-all-protocols"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "all" }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_range_contains_22" {
  expect_failure = true
  attrs = {
    name          = "internet-ssh-range"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["20-30"] }]
  }
}

resource "google_compute_firewall" "pass_disabled_rule" {
  attrs = {
    name          = "disabled-internet-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = true
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "pass_egress_rule" {
  attrs = {
    name          = "egress-ssh"
    network       = "default"
    direction     = "EGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "pass_range_excludes_22" {
  attrs = {
    name          = "internet-non-ssh-range"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["23-30"] }]
  }
}

resource "google_compute_firewall" "pass_udp_22" {
  attrs = {
    name          = "internet-udp-22"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "udp", ports = ["22"] }]
  }
}

# Omitted direction and disabled exercise provider defaults: INGRESS and false.
resource "google_compute_firewall" "fail_omitted_optional_defaults" {
  expect_failure = true
  attrs = {
    name          = "defaulted-internet-ssh"
    network       = "default"
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "pass_null_source_ranges" {
  attrs = {
    name          = "null-source-ranges"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = null
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "pass_null_allow" {
  attrs = {
    name          = "null-allow"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = null
  }
}
