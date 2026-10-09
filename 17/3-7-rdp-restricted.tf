# Test resources for policies/3-7-rdp-restricted.policy.hcl
#
# fail_rdp_open_to_world -> violates the policy (RDP open to 0.0.0.0/0)
# pass_rdp_restricted    -> complies with the policy (RDP restricted to a trusted CIDR)

resource "google_compute_firewall" "fail_rdp_open_to_world" {
  name    = "fail-rdp-open-to-world"
  network = google_compute_network.test_3_6_vpc.name

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "pass_rdp_restricted" {
  name    = "pass-rdp-restricted"
  network = google_compute_network.test_3_6_vpc.name

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"] # trusted internal range only

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}
