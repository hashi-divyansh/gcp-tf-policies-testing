# Test resources for policies/4-5-serial-ports.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf.
#
# fail_serial_ports_enabled -> violates the policy (serial-port-enable = true)
# pass_serial_ports_default -> complies with the policy (metadata key omitted, defaults to disabled)

resource "google_compute_instance" "fail_serial_ports_enabled" {
  name         = "fail-serial-ports-enabled"
  machine_type = "e2-micro"
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

  metadata = {
    serial-port-enable = "true"
  }
}

resource "google_compute_instance" "pass_serial_ports_default" {
  name         = "pass-serial-ports-default"
  machine_type = "e2-micro"
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
