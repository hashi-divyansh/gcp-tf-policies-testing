# Test resources for policies/4-6-no-ip-forward.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf.
#
# fail_ip_forward_enabled -> violates the policy (can_ip_forward = true)
# pass_ip_forward_default -> complies with the policy (attribute omitted, defaults to false)

resource "google_compute_instance" "fail_ip_forward_enabled" {
  name           = "fail-ip-forward-enabled"
  machine_type   = "e2-micro"
  zone           = "us-central1-a"
  can_ip_forward = true

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

resource "google_compute_instance" "pass_ip_forward_default" {
  name         = "pass-ip-forward-default"
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
