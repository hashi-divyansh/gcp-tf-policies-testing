# Test resources for policies/4-9-no-public-ip.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf.
#
# fail_has_public_ip -> violates the policy (access_config present, i.e. a public IP)
# pass_no_public_ip  -> complies with the policy (access_config omitted, private IP only)

resource "google_compute_instance" "fail_has_public_ip" {
  name         = "fail-has-public-ip"
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

    access_config {
      # Ephemeral public IP
    }
  }
}

resource "google_compute_instance" "pass_no_public_ip" {
  name         = "pass-no-public-ip"
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
