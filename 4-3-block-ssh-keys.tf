# Test resources for policies/4-3-block-ssh-keys.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf.
#
# fail_ssh_keys_not_blocked -> violates the policy (metadata key omitted)
# pass_ssh_keys_blocked     -> complies with the policy (block-project-ssh-keys = true)

resource "google_compute_instance" "fail_ssh_keys_not_blocked" {
  name         = "fail-ssh-keys-not-blocked"
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

resource "google_compute_instance" "pass_ssh_keys_blocked" {
  name         = "pass-ssh-keys-blocked"
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
    block-project-ssh-keys = "true"
  }
}
