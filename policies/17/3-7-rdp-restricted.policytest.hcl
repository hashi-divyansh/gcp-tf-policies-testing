# Copyright IBM Corp. 2026

policytest {
  targets = ["3-7-rdp-restricted.policy.hcl"]
}

resource "google_compute_firewall" "pass_trusted_rdp_source" {
  attrs = {
    name          = "trusted-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["192.0.2.0/24"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_exact_rdp" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_numeric_tcp_rdp" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-rdp-numeric-protocol"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "6"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_rdp_range" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-rdp-range"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3380-3390"]
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_all_tcp_ports" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-all-tcp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_all_protocols" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-all-protocols"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "all"
    }]
  }
}

# Missing direction defaults to INGRESS and remains a violation.
resource "google_compute_firewall" "fail_missing_direction" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-default-ingress"
    network       = "default"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

# Explicit null direction follows the same provider default as an omitted value.
resource "google_compute_firewall" "fail_null_direction" {
  expect_failure = true
  attrs = {
    name          = "unrestricted-null-direction"
    network       = "default"
    direction     = null
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "pass_egress_rdp" {
  attrs = {
    name               = "egress-rdp"
    network            = "default"
    direction          = "EGRESS"
    destination_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "pass_range_below_rdp" {
  attrs = {
    name          = "below-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3380-3388"]
    }]
  }
}

resource "google_compute_firewall" "pass_udp_3389" {
  attrs = {
    name          = "udp-3389"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "udp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "pass_disabled_unrestricted_rdp" {
  attrs = {
    name          = "disabled-rdp"
    network       = "default"
    direction     = "INGRESS"
    disabled      = true
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "pass_empty_allow" {
  attrs = {
    name          = "no-allowed-traffic"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow         = []
  }
}

resource "google_compute_firewall" "pass_empty_source_ranges" {
  attrs = {
    name          = "no-source-ranges"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = []
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

# source_ranges accepts IPv6 as well as IPv4, so "::/0" is just as open to
# the internet as "0.0.0.0/0".
resource "google_compute_firewall" "fail_unrestricted_ipv6_rdp" {
  expect_failure = true
  attrs = {
    name          = "ipv6-internet-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["::/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

# Non-canonical spellings of the all-addresses range are matched on their
# "/0" prefix length rather than on the literal address text.
resource "google_compute_firewall" "fail_unrestricted_ipv6_expanded_rdp" {
  expect_failure = true
  attrs = {
    name          = "ipv6-expanded-internet-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0:0:0:0:0:0:0:0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

resource "google_compute_firewall" "fail_unrestricted_dual_stack_rdp" {
  expect_failure = true
  attrs = {
    name          = "dual-stack-internet-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0", "::/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}

# A bounded IPv6 prefix is not unrestricted and must still pass.
resource "google_compute_firewall" "pass_trusted_ipv6_range_rdp" {
  attrs = {
    name          = "trusted-ipv6-rdp"
    network       = "default"
    direction     = "INGRESS"
    source_ranges = ["2001:db8::/32"]
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    }]
  }
}
