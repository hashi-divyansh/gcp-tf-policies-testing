# Copyright IBM Corp. 2026

policytest {
  targets = ["4-2-default-sa-scopes.policy.hcl"]
}

resource "google_compute_instance" "pass_without_service_account" {
  attrs = {
    name         = "pass-without-service-account"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "pass_non_default_account" {
  attrs = {
    name         = "pass-non-default-account"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "application@example-project.iam.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "pass_default_account_limited_scope" {
  attrs = {
    name         = "pass-default-account-limited-scope"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "123456789012-compute@developer.gserviceaccount.com"
      scopes = ["compute-ro"]
    }]
  }
}

resource "google_compute_instance" "fail_default_account_short_scope" {
  expect_failure = true
  attrs = {
    name         = "fail-default-account-short-scope"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "123456789012-compute@developer.gserviceaccount.com"
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "fail_default_account_oauth_url" {
  expect_failure = true
  attrs = {
    name         = "fail-default-account-oauth-url"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "123456789012-compute@developer.gserviceaccount.com"
      scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "fail_missing_email_with_full_scope" {
  expect_failure = true
  attrs = {
    name         = "fail-missing-email-with-full-scope"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      scopes = ["cloud-platform"]
    }]
  }
}

resource "google_compute_instance" "pass_empty_scopes" {
  attrs = {
    name         = "pass-empty-scopes"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "123456789012-compute@developer.gserviceaccount.com"
      scopes = []
    }]
  }
}

resource "google_compute_instance" "pass_null_scopes" {
  attrs = {
    name         = "pass-null-scopes"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk    = [{ initialize_params = [{ image = "debian-cloud/debian-12" }] }]
    network_interface = [{
      network = "default"
    }]
    service_account = [{
      email  = "123456789012-compute@developer.gserviceaccount.com"
      scopes = null
    }]
  }
}
