# Copyright IBM Corp. 2026

policytest {
  targets = ["4-4-os-login.policy.hcl"]
}

resource "google_compute_project_metadata" "pass_project_oslogin_true" {
  attrs = {
    metadata = { enable-oslogin = "TRUE" }
  }
}

resource "google_compute_project_metadata" "pass_project_oslogin_lowercase_true" {
  attrs = {
    metadata = { enable-oslogin = "true", other = "x" }
  }
}

resource "google_compute_project_metadata" "fail_project_oslogin_false" {
  expect_failure = true
  attrs = {
    metadata = { enable-oslogin = "FALSE" }
  }
}

# An unset enable-oslogin key is equivalent to FALSE.
resource "google_compute_project_metadata" "fail_project_oslogin_unset" {
  expect_failure = true
  attrs = {
    metadata = { serial-port-enable = "FALSE" }
  }
}

resource "google_compute_project_metadata_item" "pass_project_item_true" {
  attrs = {
    key   = "enable-oslogin"
    value = "TRUE"
  }
}

resource "google_compute_project_metadata_item" "fail_project_item_false" {
  expect_failure = true
  attrs = {
    key   = "enable-oslogin"
    value = "false"
  }
}

resource "google_compute_project_metadata_item" "pass_unrelated_project_item" {
  attrs = {
    key   = "serial-port-enable"
    value = "FALSE"
  }
}

resource "google_compute_instance" "pass_instance_inherits_project_setting" {
  attrs = {
    name         = "pass-instance-inherits-project-setting"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    metadata     = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "pass_instance_oslogin_true" {
  attrs = {
    name         = "pass-instance-oslogin-true"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    metadata     = { enable-oslogin = "TRUE" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_instance_oslogin_false" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-oslogin-false"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    metadata     = { enable-oslogin = "FALSE" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_instance_oslogin_unrecognized_value" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-oslogin-unrecognized-value"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    metadata     = { enable-oslogin = "disabled" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

# A hand-authored instance cannot prove it is a real GKE node, so a gke- name
# and goog-gke-node label do not exempt it (same as 4-9).
resource "google_compute_instance" "fail_gke_named_instance_oslogin_false" {
  expect_failure = true
  attrs = {
    name         = "fail-gke-named-instance-oslogin-false"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = { goog-gke-node = "true" }
    metadata     = { enable-oslogin = "FALSE" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance_from_template" "fail_instance_from_template_oslogin_false" {
  expect_failure = true
  attrs = {
    name                     = "from-template"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
    metadata                 = { enable-oslogin = "FALSE" }
  }
}

resource "google_compute_instance_from_template" "pass_instance_from_template_no_override" {
  attrs = {
    name                     = "from-template-ok"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
  }
}

resource "google_compute_instance_template" "pass_template_oslogin_true" {
  attrs = {
    name         = "template-ok"
    machine_type = "e2-micro"
    metadata     = { enable-oslogin = "TRUE" }
    disk         = [{ source_image = "debian-cloud/debian-12" }]
  }
}

resource "google_compute_instance_template" "fail_template_oslogin_false" {
  expect_failure = true
  attrs = {
    name         = "template-bad"
    machine_type = "e2-micro"
    metadata     = { enable-oslogin = "FALSE" }
    disk         = [{ source_image = "debian-cloud/debian-12" }]
  }
}

resource "google_compute_region_instance_template" "fail_region_template_oslogin_false" {
  expect_failure = true
  attrs = {
    name         = "region-template-bad"
    region       = "us-central1"
    machine_type = "e2-micro"
    metadata     = { enable-oslogin = "0" }
    disk         = [{ source_image = "debian-cloud/debian-12" }]
  }
}

# Only values that both Google's metadata docs and the guest agent's
# strconv.ParseBool treat as true are accepted: "yes"/"y" are ignored by the
# agent, "T"/"t" are not documented, and padded values parse as neither.
resource "google_compute_project_metadata" "fail_project_oslogin_yes" {
  expect_failure = true
  attrs = {
    metadata = { enable-oslogin = "yes" }
  }
}

resource "google_compute_project_metadata_item" "fail_project_item_padded_true" {
  expect_failure = true
  attrs = {
    key   = "enable-oslogin"
    value = " TRUE"
  }
}

resource "google_compute_project_metadata_item" "fail_project_item_t" {
  expect_failure = true
  attrs = {
    key   = "enable-oslogin"
    value = "T"
  }
}

resource "google_compute_project_metadata_item" "pass_project_item_one" {
  attrs = {
    key   = "enable-oslogin"
    value = "1"
  }
}

resource "google_compute_project_metadata" "pass_project_oslogin_title_case" {
  attrs = {
    metadata = { enable-oslogin = "True" }
  }
}

resource "google_compute_project_metadata_item" "fail_project_item_empty" {
  expect_failure = true
  attrs = {
    key   = "enable-oslogin"
    value = ""
  }
}

# Google documents "Y" as a TRUE alias, but the guest agent ignores it, so an
# instance override of "Y" does not reliably keep OS Login enabled.
resource "google_compute_instance" "fail_instance_oslogin_y" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-oslogin-y"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    metadata     = { enable-oslogin = "Y" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

# Omitting metadata entirely inherits the project-wide setting.
resource "google_compute_instance" "pass_instance_metadata_omitted" {
  attrs = {
    name         = "pass-instance-metadata-omitted"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_region_instance_template" "pass_region_template_no_override" {
  attrs = {
    name         = "region-template-ok"
    region       = "us-central1"
    machine_type = "e2-micro"
    metadata     = { startup-script = "echo ok" }
    disk         = [{ source_image = "debian-cloud/debian-12" }]
  }
}

resource "google_compute_instance_template" "fail_template_oslogin_yes" {
  expect_failure = true
  attrs = {
    name         = "template-yes"
    machine_type = "e2-micro"
    metadata     = { enable-oslogin = "Yes" }
    disk         = [{ source_image = "debian-cloud/debian-12" }]
  }
}

resource "google_compute_project_metadata_item" "fail_project_item_mixed_case" {
  expect_failure = true
  attrs = {
    key   = "enable-oslogin"
    value = "tRuE"
  }
}
