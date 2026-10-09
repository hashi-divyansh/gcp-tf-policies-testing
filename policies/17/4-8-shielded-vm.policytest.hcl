# Copyright IBM Corp. 2026

policytest {
  targets = ["4-8-shielded-vm.policy.hcl"]
}

resource "google_compute_instance" "pass_required_controls_enabled" {
  attrs = {
    name         = "pass-required-controls-enabled"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = [{
      enable_vtpm                 = true
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }]
  }
}

resource "google_compute_instance" "fail_missing_shielded_config" {
  expect_failure = true
  attrs = {
    name         = "fail-missing-shielded-config"
    machine_type = "e2-micro"
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

resource "google_compute_instance" "fail_null_shielded_config" {
  expect_failure = true
  attrs = {
    name         = "fail-null-shielded-config"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = null
  }
}

# Block can't be fully empty (provider's at_least_one_of), so only
# enable_secure_boot is set; vtpm/integrity_monitoring use their true defaults.
resource "google_compute_instance" "pass_partial_shielded_config_uses_defaults" {
  attrs = {
    name         = "pass-partial-shielded-config"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = [{
      enable_secure_boot = true
    }]
  }
}

resource "google_compute_instance" "fail_vtpm_disabled" {
  expect_failure = true
  attrs = {
    name         = "fail-vtpm-disabled"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = [{
      enable_vtpm                 = false
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }]
  }
}

resource "google_compute_instance" "fail_integrity_monitoring_disabled" {
  expect_failure = true
  attrs = {
    name         = "fail-integrity-monitoring-disabled"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = [{
      enable_vtpm                 = true
      enable_integrity_monitoring = false
      enable_secure_boot          = true
    }]
  }
}

# enable_secure_boot defaults to false, unlike vtpm/integrity_monitoring which
# default to true, so it must be explicitly disabled to test this case.
resource "google_compute_instance" "fail_secure_boot_disabled" {
  expect_failure = true
  attrs = {
    name         = "fail-secure-boot-disabled"
    machine_type = "e2-micro"
    boot_disk = [{
      initialize_params = [{
        image = "debian-cloud/debian-12"
      }]
    }]
    network_interface = [{
      network = "default"
    }]
    shielded_instance_config = [{
      enable_vtpm                 = true
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }]
  }
}
