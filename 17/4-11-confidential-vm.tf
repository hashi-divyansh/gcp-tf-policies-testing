# Test resources for policies/4-11-confidential-vm.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf. Confidential Computing
# is only supported on N2D/C2D/N3D machine types, so both instances below
# use n2d-standard-2 (out-of-family machine types are out of policy scope
# entirely, see 4-11-confidential-vm.policy.hcl).
#
# fail_confidential_compute_disabled -> violates the policy (confidential_instance_config omitted)
# pass_confidential_compute_enabled  -> complies with the policy (enable_confidential_compute = true)

resource "google_compute_instance" "fail_confidential_compute_disabled" {
  name         = "fail-confidential-compute-disabled"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.test_3_6_vpc.name
    subnetwork = google_compute_subnetwork.shared_subnet.name
  }
}

resource "google_compute_instance" "pass_confidential_compute_enabled" {
  name         = "pass-confidential-compute-enabled"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.test_3_6_vpc.name
    subnetwork = google_compute_subnetwork.shared_subnet.name
  }

  confidential_instance_config {
    enable_confidential_compute = true
  }

  # Confidential Computing requires the instance to terminate rather than
  # live-migrate during host maintenance.
  scheduling {
    on_host_maintenance = "TERMINATE"
  }
}
