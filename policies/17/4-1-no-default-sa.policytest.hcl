# Copyright IBM Corp. 2026

policytest {
  targets = ["4-1-no-default-sa.policy.hcl"]
}

resource "google_compute_instance" "pass_custom_service_account" {
  attrs = {
    name         = "custom-service-account-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{ network = "default" }]
    service_account = [{
      email  = "application@validation-project.iam.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "fail_default_service_account" {
  expect_failure = true
  attrs = {
    name         = "default-service-account-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{ network = "default" }]
    service_account = [{
      email  = "123456789-compute@developer.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "fail_missing_service_account" {
  expect_failure = true
  attrs = {
    name         = "missing-service-account-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{ network = "default" }]
  }
}

resource "google_compute_instance" "fail_empty_service_account" {
  expect_failure = true
  attrs = {
    name              = "empty-service-account-instance"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    service_account   = []
  }
}

resource "google_compute_instance" "fail_null_service_account" {
  expect_failure = true
  attrs = {
    name              = "null-service-account-instance"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    service_account   = null
  }
}

resource "google_compute_instance" "fail_missing_email" {
  expect_failure = true
  attrs = {
    name              = "missing-email-instance"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    service_account   = [{ scopes = ["cloud-platform"] }]
  }
}

resource "google_compute_instance" "fail_empty_email" {
  expect_failure = true
  attrs = {
    name              = "empty-email-instance"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    service_account = [{
      email  = ""
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "fail_null_email" {
  expect_failure = true
  attrs = {
    name              = "null-email-instance"
    machine_type      = "e2-micro"
    zone              = "us-central1-a"
    boot_disk         = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{ network = "default" }]
    service_account = [{
      email  = null
      scopes = ["cloud-platform"]
    }]
  }
}
