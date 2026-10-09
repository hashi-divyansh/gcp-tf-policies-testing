# Test resources for policies/30/4-7-csek-disks.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_disk_google_managed       -> violates the policy (default Google-managed encryption)
# fail_disk_cmek                 -> violates the policy (CMEK is not CSEK)
# pass_disk_csek                 -> complies with the policy (disk_encryption_key.raw_key)
# fail_instance_boot_google_managed -> violates the policy (boot disk without CSEK)
# pass_instance_boot_csek        -> complies with the policy (boot disk_encryption_key_raw)
#
# The CSEK value is a dummy base64 test key, not a real secret.

resource "google_compute_disk" "fail_disk_google_managed" {
  name = "fail-disk-google-managed"
  zone = "us-central1-a"
  size = 10
  type = "pd-standard"

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_disk" "fail_disk_cmek" {
  name = "fail-disk-cmek"
  zone = "us-central1-a"
  size = 10
  type = "pd-standard"
  disk_encryption_key {
    kms_key_self_link = "projects/${var.project_id}/locations/us-central1/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_disk" "pass_disk_csek" {
  name = "pass-disk-csek"
  zone = "us-central1-a"
  size = 10
  type = "pd-standard"
  disk_encryption_key {
    raw_key = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_instance" "fail_instance_boot_google_managed" {
  name         = "fail-instance-boot-google-managed"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = "projects/${var.project_id}/regions/us-central1/subnetworks/policy-test-subnet"
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_instance" "pass_instance_boot_csek" {
  name         = "pass-instance-boot-csek"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
    disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
  }

  network_interface {
    subnetwork = "projects/${var.project_id}/regions/us-central1/subnetworks/policy-test-subnet"
  }

  depends_on = [time_sleep.prerequisites_ready]
}
