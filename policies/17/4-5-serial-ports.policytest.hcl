# Copyright IBM Corp. 2026

policytest {
  targets = ["4-5-serial-ports.policy.hcl"]
}

resource "google_compute_instance" "pass_metadata_omitted" {
  attrs = {
    name         = "metadata-omitted"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{ network = "default" }]
  }
}

resource "google_compute_instance" "pass_serial_key_omitted" {
  attrs = {
    name              = "serial-key-omitted"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { environment = "test" }
  }
}

resource "google_compute_instance" "pass_serial_disabled_false" {
  attrs = {
    name              = "serial-disabled-false"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "false" }
  }
}

resource "google_compute_instance" "pass_serial_disabled_zero" {
  attrs = {
    name              = "serial-disabled-zero"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "0" }
  }
}

resource "google_compute_instance" "pass_serial_disabled_uppercase" {
  attrs = {
    name              = "serial-disabled-uppercase"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "FALSE" }
  }
}

resource "google_compute_instance" "pass_serial_disabled_no_alias" {
  attrs = {
    name              = "serial-disabled-no-alias"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "No" }
  }
}

resource "google_compute_instance" "fail_serial_enabled_true" {
  expect_failure = true
  attrs = {
    name              = "serial-enabled-true"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "true" }
  }
}

resource "google_compute_instance" "fail_serial_enabled_yes_alias" {
  expect_failure = true
  attrs = {
    name              = "serial-enabled-yes-alias"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "Yes" }
  }
}

resource "google_compute_instance" "fail_serial_value_empty" {
  expect_failure = true
  attrs = {
    name              = "serial-value-empty"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "" }
  }
}

# Project-wide google_compute_project_metadata directly enabling serial
# port access must fail on its own.
resource "google_compute_project_metadata" "fail_project_metadata_enabled" {
  expect_failure = true
  attrs = {
    project  = "project-metadata-enabled"
    metadata = { "serial-port-enable" = "true" }
  }
}

resource "google_compute_project_metadata" "pass_project_metadata_disabled" {
  attrs = {
    project  = "project-metadata-disabled"
    metadata = { "serial-port-enable" = "false" }
  }
}

# Project-wide google_compute_project_metadata_item directly enabling
# serial port access must fail on its own.
resource "google_compute_project_metadata_item" "fail_project_metadata_item_enabled" {
  expect_failure = true
  attrs = {
    project = "project-metadata-item-enabled"
    key     = "serial-port-enable"
    value   = "true"
  }
}

resource "google_compute_project_metadata_item" "pass_project_metadata_item_disabled" {
  attrs = {
    project = "project-metadata-item-disabled"
    key     = "serial-port-enable"
    value   = "false"
  }
}

resource "google_compute_project_metadata_item" "pass_unrelated_metadata_item" {
  attrs = {
    project = "project-metadata-item-unrelated"
    key     = "windows-startup-script-url"
    value   = "gs://example-bucket/startup.ps1"
  }
}

# An instance that omits its own key inherits a truthy project-wide value
# (from either resource type) and must fail even though it sets nothing
# itself. This source resource also fails its own direct check, since it
# enables serial port access at the project level.
resource "google_compute_project_metadata" "inherit_via_project_metadata_source" {
  expect_failure = true
  attrs = {
    project  = "inherits-project-metadata"
    metadata = { "serial-port-enable" = "true" }
  }
}

resource "google_compute_instance" "fail_inherits_enabled_project_metadata" {
  expect_failure = true
  attrs = {
    name              = "inherits-enabled-project-metadata"
    project           = "inherits-project-metadata"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
  }
}

resource "google_compute_project_metadata_item" "inherit_via_project_metadata_item_source" {
  expect_failure = true
  attrs = {
    project = "inherits-project-metadata-item"
    key     = "serial-port-enable"
    value   = "true"
  }
}

resource "google_compute_instance" "fail_inherits_enabled_project_metadata_item" {
  expect_failure = true
  attrs = {
    name              = "inherits-enabled-project-metadata-item"
    project           = "inherits-project-metadata-item"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
  }
}

# An instance in a *different* project must not be affected by another
# project's truthy metadata.
resource "google_compute_instance" "pass_different_project_not_affected" {
  attrs = {
    name              = "different-project-instance"
    project           = "unrelated-project"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
  }
}

# An explicit instance-level override (disabling) must pass even though the
# project-wide metadata for the same project enables it.
resource "google_compute_instance" "pass_instance_override_disables_inherited_enable" {
  attrs = {
    name              = "instance-override-disables-inherited"
    project           = "inherits-project-metadata"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    metadata          = { "serial-port-enable" = "false" }
  }
}
