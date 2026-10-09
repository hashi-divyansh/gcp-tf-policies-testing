# Test resources for policies/4-8-shielded-vm.policy.hcl
#
# ⚠️ See the cost/time note in 4-1-no-default-sa.tf.
#
# fail_shielded_vm_missing -> violates the policy (shielded_instance_config omitted)
# pass_shielded_vm_enabled -> complies with the policy (vtpm, integrity monitoring,
#                             and secure boot all explicitly true)

resource "google_compute_instance" "fail_shielded_vm_missing" {
  name         = "fail-shielded-vm-missing"
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

resource "google_compute_instance" "pass_shielded_vm_enabled" {
  name         = "pass-shielded-vm-enabled"
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

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
    enable_secure_boot          = true
  }
}
