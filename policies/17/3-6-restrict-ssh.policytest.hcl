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

resource "google_compute_firewall" "fail_unrestricted_numeric_tcp_22" {
  expect_failure = true
  attrs = {
    name          = "internet-ssh-numeric-protocol"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0"]
    allow         = [{ protocol = "6", ports = ["22"] }]
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

# source_ranges accepts IPv6 as well as IPv4, so "::/0" is just as open to
# the internet as "0.0.0.0/0".
resource "google_compute_firewall" "fail_unrestricted_ipv6" {
  expect_failure = true
  attrs = {
    name          = "ipv6-internet-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["::/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

# Non-canonical spellings of the all-addresses range are matched on their
# "/0" prefix length rather than on the literal address text.
resource "google_compute_firewall" "fail_unrestricted_ipv6_expanded" {
  expect_failure = true
  attrs = {
    name          = "ipv6-expanded-internet-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0:0:0:0:0:0:0:0/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_dual_stack" {
  expect_failure = true
  attrs = {
    name          = "dual-stack-internet-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["0.0.0.0/0", "::/0"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}

# A bounded IPv6 prefix is not unrestricted and must still pass.
resource "google_compute_firewall" "pass_trusted_ipv6_range" {
  attrs = {
    name          = "trusted-ipv6-ssh"
    network       = "default"
    direction     = "INGRESS"
    disabled      = false
    source_ranges = ["2001:db8::/32"]
    allow         = [{ protocol = "tcp", ports = ["22"] }]
  }
}
