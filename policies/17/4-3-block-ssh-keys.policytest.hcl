# Copyright IBM Corp. 2026

policytest {
  targets = ["4-3-block-ssh-keys.policy.hcl"]
}

resource "google_compute_instance" "pass_block_project_ssh_keys_true" {
  attrs = {
    name         = "pass-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    metadata = {
      block-project-ssh-keys = "TRUE"
    }
  }
}

resource "google_compute_instance" "fail_metadata_omitted" {
  expect_failure = true
  attrs = {
    name         = "missing-metadata-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_metadata_empty" {
  expect_failure = true
  attrs = {
    name         = "empty-metadata-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    metadata = {}
  }
}

resource "google_compute_instance" "fail_metadata_null" {
  expect_failure = true
  attrs = {
    name         = "null-metadata-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    metadata = null
  }
}

# GCP metadata booleans are case-insensitive, so a lowercase "true" is
# actually a valid, compliant value and must pass.
resource "google_compute_instance" "pass_block_project_ssh_keys_lowercase" {
  attrs = {
    name         = "lowercase-value-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    metadata = {
      block-project-ssh-keys = "true"
    }
  }
}

resource "google_compute_instance" "fail_block_project_ssh_keys_invalid_value" {
  expect_failure = true
  attrs = {
    name         = "invalid-value-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    metadata = {
      block-project-ssh-keys = "enabled"
    }
  }
}
