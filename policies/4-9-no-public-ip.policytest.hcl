# Copyright IBM Corp. 2026

policytest {
  targets = ["4-9-no-public-ip.policy.hcl"]
}

resource "google_compute_instance" "pass_without_public_access" {
  attrs = {
    name         = "private-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = []
      ipv6_access_config = []
    }]
  }
}

resource "google_compute_instance" "pass_gke_exception" {
  attrs = {
    name         = "gke-cluster-default-pool-node"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = { goog-gke-node = "true" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = [{}]
      ipv6_access_config = [{ network_tier = "PREMIUM" }]
    }]
  }
}

resource "google_compute_instance" "fail_ephemeral_ipv4" {
  expect_failure = true
  attrs = {
    name         = "ephemeral-ipv4-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = [{}]
      ipv6_access_config = []
    }]
  }
}

resource "google_compute_instance" "fail_static_ipv4" {
  expect_failure = true
  attrs = {
    name         = "static-ipv4-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = [{ nat_ip = "198.51.100.10" }]
      ipv6_access_config = []
    }]
  }
}

resource "google_compute_instance" "fail_external_ipv6" {
  expect_failure = true
  attrs = {
    name         = "external-ipv6-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = []
      ipv6_access_config = [{ network_tier = "PREMIUM" }]
    }]
  }
}

resource "google_compute_instance" "fail_later_interface_public" {
  expect_failure = true
  attrs = {
    name         = "multiple-interface-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = {}
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [
      {
        network            = "default"
        access_config      = []
        ipv6_access_config = []
      },
      {
        network            = "secondary"
        access_config      = [{}]
        ipv6_access_config = []
      }
    ]
  }
}

# Missing the optional labels attribute must not activate the GKE exception.
resource "google_compute_instance" "fail_gke_name_without_label" {
  expect_failure = true
  attrs = {
    name         = "gke-unmarked-instance"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = [{}]
      ipv6_access_config = []
    }]
  }
}

resource "google_compute_instance" "fail_gke_label_without_name_prefix" {
  expect_failure = true
  attrs = {
    name         = "unprefixed-gke-node"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    labels       = { goog-gke-node = "true" }
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
    }]
    network_interface = [{
      network            = "default"
      access_config      = [{}]
      ipv6_access_config = []
    }]
  }
}
