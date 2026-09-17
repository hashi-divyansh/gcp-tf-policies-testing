# Copyright IBM Corp. 2026

policytest {
  targets = ["4-6-no-ip-forward.policy.hcl"]
}

resource "google_compute_instance" "pass_can_ip_forward_omitted" {
  attrs = {
    name         = "pass-omitted"
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

resource "google_compute_instance" "pass_can_ip_forward_false" {
  attrs = {
    name           = "pass-false"
    machine_type   = "e2-micro"
    zone           = "us-central1-a"
    can_ip_forward = false
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

resource "google_compute_instance" "pass_can_ip_forward_null" {
  attrs = {
    name           = "pass-null"
    machine_type   = "e2-micro"
    zone           = "us-central1-a"
    can_ip_forward = null
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

resource "google_compute_instance" "fail_can_ip_forward_true" {
  expect_failure = true
  attrs = {
    name           = "fail-true"
    machine_type   = "e2-micro"
    zone           = "us-central1-a"
    can_ip_forward = true
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
