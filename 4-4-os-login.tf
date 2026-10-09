# Test resources for policies/30/4-4-os-login.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_project_oslogin_false     -> violates the policy (project item enable-oslogin = FALSE)
# fail_instance_oslogin_false    -> violates the policy (instance overrides enable-oslogin = FALSE)
# pass_instance_inherits_project -> complies with the policy (no instance override)
# pass_instance_oslogin_true     -> complies with the policy (enable-oslogin = TRUE)
#
# Only a metadata item is used for the project level, so this does not overwrite
# all project metadata. Applying it changes project-wide OS Login.
# These VMs use Google-managed disk encryption, so they also fail 4.7.

resource "google_compute_project_metadata_item" "fail_project_oslogin_false" {
  key   = "enable-oslogin"
  value = "FALSE"

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_instance" "fail_instance_oslogin_false" {
  name         = "fail-instance-oslogin-false"
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
  metadata = {
    enable-oslogin = "FALSE"
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_compute_instance" "pass_instance_inherits_project" {
  name         = "pass-instance-inherits-project"
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

resource "google_compute_instance" "pass_instance_oslogin_true" {
  name         = "pass-instance-oslogin-true"
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
  metadata = {
    enable-oslogin = "TRUE"
  }

  depends_on = [time_sleep.prerequisites_ready]
}
