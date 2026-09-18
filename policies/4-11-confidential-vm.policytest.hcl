# Copyright IBM Corp. 2026

policytest {
  targets = ["4-11-confidential-vm.policy.hcl"]
}

resource "google_compute_instance" "pass_confidential_computing_enabled" {
  attrs = {
    name         = "pass-confidential-vm"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = true
    }
  }
}

resource "google_compute_instance" "fail_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-missing-confidential-config"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
  }
}

resource "google_compute_instance" "fail_missing_enable_attribute" {
  expect_failure = true
  attrs = {
    name         = "fail-missing-enable-attribute"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {}
  }
}

resource "google_compute_instance" "fail_null_enable_attribute" {
  expect_failure = true
  attrs = {
    name         = "fail-null-enable-attribute"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = null
    }
  }
}

resource "google_compute_instance" "fail_confidential_computing_disabled" {
  expect_failure = true
  attrs = {
    name         = "fail-confidential-computing-disabled"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = false
    }
  }
}

# Machine types outside the supported Confidential Computing families
# (n2d, c2d, c3d, c4d, c3, c4) cannot enable Confidential Computing at all,
# so they are out of scope and must pass regardless of
# confidential_instance_config.
resource "google_compute_instance" "pass_unsupported_machine_type_missing_config" {
  attrs = {
    name         = "pass-unsupported-machine-type"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
  }
}

resource "google_compute_instance" "pass_c2d_case_insensitive_match" {
  attrs = {
    name         = "pass-c2d-case-insensitive"
    machine_type = "C2D-standard-4"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = true
    }
  }
}

resource "google_compute_instance" "pass_c3d_confidential_enabled" {
  attrs = {
    name         = "pass-c3d-confidential-vm"
    machine_type = "c3d-standard-4"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = true
    }
  }
}

resource "google_compute_instance" "fail_c4d_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-c4d-missing-confidential-config"
    machine_type = "c4d-standard-4"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
  }
}

# "c3" and "c4" are two-character family tokens; confirm the family parsing
# does not require a fixed 3-character prefix match.
resource "google_compute_instance" "pass_c3_confidential_enabled" {
  attrs = {
    name         = "pass-c3-confidential-vm"
    machine_type = "c3-standard-4"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
    confidential_instance_config = {
      enable_confidential_compute = true
    }
  }
}

resource "google_compute_instance" "fail_c4_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-c4-missing-confidential-config"
    machine_type = "c4-standard-4"
    zone         = "us-central1-a"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
      }
    }
    network_interface = {
      network = "default"
    }
  }
}
