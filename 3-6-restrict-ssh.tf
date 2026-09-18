# Test resources for policies/3-6-restrict-ssh.policy.hcl
#
# fail_ssh_open_to_world  -> violates the policy (SSH open to 0.0.0.0/0)
# pass_ssh_restricted     -> complies with the policy (SSH restricted to a trusted CIDR)

resource "google_compute_network" "test_3_6_vpc" {
  name                    = "policy-test-3-6-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "fail_ssh_open_to_world" {
  name    = "fail-ssh-open-to-world"
  network = google_compute_network.test_3_6_vpc.name

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "pass_ssh_restricted" {
  name    = "pass-ssh-restricted"
  network = google_compute_network.test_3_6_vpc.name

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8"] # trusted internal range only

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
