# Copyright IBM Corp. 2026

policytest {
  targets = ["4-7-csek-disks.policy.hcl"]
}

# Exercises the csek-disks-critical-label-key input (CIS "critical VMs" scoping).
inputs {
  csek-disks-critical-label-key = "critical"
}

# Only resources labeled with the configured key are evaluated.
resource "google_compute_disk" "pass_unlabeled_disk_out_of_scope" {
  attrs = {
    name = "pass-unlabeled-disk-out-of-scope"
    zone = "us-central1-a"
    size = 10
  }
}

resource "google_compute_disk" "fail_critical_disk_google_managed" {
  expect_failure = true
  attrs = {
    name   = "fail-critical-disk-google-managed"
    zone   = "us-central1-a"
    size   = 10
    labels = { critical = "true" }
  }
}

resource "google_compute_disk" "pass_critical_disk_raw_key" {
  attrs = {
    name                = "pass-critical-disk-raw-key"
    zone                = "us-central1-a"
    size                = 10
    labels              = { critical = "true" }
    disk_encryption_key = [{ raw_key = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0=" }]
  }
}

resource "google_compute_instance" "pass_unlabeled_instance_out_of_scope" {
  attrs = {
    name         = "pass-unlabeled-instance-out-of-scope"
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

resource "google_compute_instance" "fail_critical_instance_google_managed" {
  expect_failure = true
  attrs = {
    name         = "fail-critical-instance-google-managed"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = { critical = "true" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

# The label key puts a resource in scope regardless of its value.
resource "google_compute_disk" "fail_critical_label_false_value_in_scope" {
  expect_failure = true
  attrs = {
    name   = "fail-critical-label-false-value-in-scope"
    zone   = "us-central1-a"
    size   = 10
    labels = { critical = "false" }
  }
}

# A critical label from provider default_labels appears only in
# terraform_labels, and must still put the resource in scope.
resource "google_compute_disk" "fail_critical_default_label_disk" {
  expect_failure = true
  attrs = {
    name             = "fail-critical-default-label-disk"
    zone             = "us-central1-a"
    size             = 10
    terraform_labels = { critical = "true" }
  }
}

resource "google_compute_instance" "fail_critical_default_label_instance" {
  expect_failure = true
  attrs = {
    name             = "fail-critical-default-label-instance"
    machine_type     = "e2-micro"
    zone             = "us-central1-a"
    terraform_labels = { critical = "true", env = "prod" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "pass_other_label_instance_out_of_scope" {
  attrs = {
    name         = "pass-other-label-instance-out-of-scope"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = { env = "prod" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_region_disk" "pass_unlabeled_region_disk_out_of_scope" {
  attrs = {
    name          = "pass-unlabeled-region-disk-out-of-scope"
    region        = "us-central1"
    replica_zones = ["us-central1-a", "us-central1-b"]
    size          = 10
  }
}

resource "google_compute_region_disk" "fail_critical_region_disk_google_managed" {
  expect_failure = true
  attrs = {
    name          = "fail-critical-region-disk-google-managed"
    region        = "us-central1"
    replica_zones = ["us-central1-a", "us-central1-b"]
    size          = 10
    labels        = { critical = "true" }
  }
}

resource "google_compute_instance_from_template" "pass_unlabeled_from_template_out_of_scope" {
  attrs = {
    name                     = "from-template-out-of-scope"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
  }
}

resource "google_compute_instance_from_template" "fail_critical_from_template_template_disks" {
  expect_failure = true
  attrs = {
    name                     = "from-template-critical"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
    labels                   = { critical = "true" }
  }
}
