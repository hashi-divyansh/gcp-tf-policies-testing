# Test resources for policies/4-1-no-default-sa.policy.hcl
#
# ⚠️ google_compute_instance resources cost money and take longer to
# create/destroy than network/firewall resources. `terraform plan` alone is
# enough to see the policy evaluation results below; only `apply` if you
# want to verify against a real running instance.
#
# fail_uses_default_sa -> violates the policy (omits service_account, so it
#                         falls back to the project's default Compute Engine SA)
# pass_uses_custom_sa  -> complies with the policy (explicit custom service account)

resource "google_compute_instance" "fail_uses_default_sa" {
  name         = "fail-uses-default-sa"
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

resource "google_compute_instance" "pass_uses_custom_sa" {
  name         = "pass-uses-custom-sa"
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

  service_account {
    email  = "hcp-terraform-runner@hc-f31985686df247b5bbd6a432306.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
