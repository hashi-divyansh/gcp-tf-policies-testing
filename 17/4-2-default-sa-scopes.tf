# Test resources for policies/4-2-default-sa-scopes.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf -- `terraform plan` alone
# is enough to see the policy evaluation results below.
#
# fail_default_sa_full_access -> violates the policy (omits service_account.email,
#                                 which resolves to the default SA, combined with
#                                 the full-access cloud-platform scope)
# pass_custom_sa_scopes        -> complies with the policy (custom, non-default SA)

resource "google_compute_instance" "fail_default_sa_full_access" {
  name         = "fail-default-sa-full-access"
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
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "pass_custom_sa_scopes" {
  name         = "pass-custom-sa-scopes"
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
