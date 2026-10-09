# Copyright IBM Corp. 2026

policytest {
  targets = ["4-11-confidential-vm.policy.hcl"]
}

resource "google_compute_instance" "pass_confidential_computing_enabled" {
  attrs = {
    name         = "pass-confidential-vm"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = true
    }]
  }
}

resource "google_compute_instance" "fail_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-missing-confidential-config"
    machine_type = "n2d-standard-2"
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

resource "google_compute_instance" "pass_confidential_instance_type_only" {
  attrs = {
    name         = "pass-confidential-type-only"
    machine_type = "c3-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      confidential_instance_type = "TDX"
    }]
  }
}

resource "google_compute_instance" "pass_null_legacy_flag_with_type" {
  attrs = {
    name         = "pass-null-legacy-flag"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = null
      confidential_instance_type  = "SEV_SNP"
    }]
  }
}

resource "google_compute_instance" "pass_sev_instance_type" {
  attrs = {
    name         = "pass-sev-instance-type"
    machine_type = "c2d-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      confidential_instance_type = "SEV"
    }]
  }
}

# The provider omits false from the API request when a valid type is set,
# so GCP still creates a Confidential VM.
resource "google_compute_instance" "pass_disabled_legacy_flag_with_type" {
  attrs = {
    name         = "pass-disabled-legacy-flag-with-type"
    machine_type = "c3-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = false
      confidential_instance_type  = "TDX"
    }]
  }
}

resource "google_compute_instance" "fail_confidential_computing_disabled" {
  expect_failure = true
  attrs = {
    name         = "fail-confidential-computing-disabled"
    machine_type = "n2d-standard-2"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = false
    }]
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

resource "google_compute_instance" "pass_c2d_case_insensitive_match" {
  attrs = {
    name         = "pass-c2d-case-insensitive"
    machine_type = "C2D-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = true
    }]
  }
}

resource "google_compute_instance" "pass_c3d_confidential_enabled" {
  attrs = {
    name         = "pass-c3d-confidential-vm"
    machine_type = "c3d-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = true
    }]
  }
}

resource "google_compute_instance" "fail_c4d_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-c4d-missing-confidential-config"
    machine_type = "c4d-standard-4"
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

# "c3" and "c4" are two-character family tokens; confirm the family parsing
# does not require a fixed 3-character prefix match.
resource "google_compute_instance" "pass_c3_confidential_enabled" {
  attrs = {
    name         = "pass-c3-confidential-vm"
    machine_type = "c3-standard-4"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    confidential_instance_config = [{
      enable_confidential_compute = true
    }]
  }
}

resource "google_compute_instance" "fail_c4_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-c4-missing-confidential-config"
    machine_type = "c4-standard-4"
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

resource "google_compute_instance" "pass_c3_highcpu_without_confidential_config" {
  attrs = {
    name         = "pass-c3-highcpu"
    machine_type = "c3-highcpu-8"
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

resource "google_compute_instance" "pass_c4_highmem_without_confidential_config" {
  attrs = {
    name         = "pass-c4-highmem"
    machine_type = "c4-highmem-8"
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

resource "google_compute_instance" "pass_c4d_bare_metal_without_confidential_config" {
  attrs = {
    name         = "pass-c4d-bare-metal"
    machine_type = "c4d-standard-384-metal"
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

resource "google_compute_instance" "pass_c4d_384_vcpu_without_confidential_config" {
  attrs = {
    name         = "pass-c4d-384-vcpu"
    machine_type = "c4d-highcpu-384"
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

resource "google_compute_instance" "fail_c3_standard_url_missing_confidential_config" {
  expect_failure = true
  attrs = {
    name         = "fail-c3-standard-url"
    machine_type = "https://www.googleapis.com/compute/v1/projects/test-project/zones/us-central1-a/machineTypes/c3-standard-4"
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
