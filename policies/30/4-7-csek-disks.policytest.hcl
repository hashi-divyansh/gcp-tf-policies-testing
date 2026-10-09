# Copyright IBM Corp. 2026

policytest {
  targets = ["4-7-csek-disks.policy.hcl"]
}

resource "google_compute_disk" "pass_disk_raw_key" {
  attrs = {
    name                = "pass-disk-raw-key"
    zone                = "us-central1-a"
    size                = 10
    disk_encryption_key = [{ raw_key = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0=" }]
  }
}

resource "google_compute_disk" "pass_disk_rsa_encrypted_key" {
  attrs = {
    name                = "pass-disk-rsa-encrypted-key"
    zone                = "us-central1-a"
    size                = 10
    disk_encryption_key = [{ rsa_encrypted_key = "ieCx/NcW06PcT7Ep1X6LUTc/hLvUDYyzSZPPVCVPTVEohpeHASqC8uw5TzyO9U+Fka9JFHz0mBibXUInrC/jEk014kCK/NPjYgEMOyssZ4ZINPKxlUh2zn1bV+MCaTICrdmuSBTWlUUiFoDD6PYznLwh8ZNdaheCeZ8ewEXgFQ8V+sDroLaN3Xs3MDTXQEMMoNUXMCZEIpg9Vtp9x2oeQ5lAbtt7bYAAHf5l+gJWw3sUfs0/Glw5fpdjT8Uggrr+RMZezGrltJEF293rvTIjWOEB3z5OHyHwQkvdrPDFcTqsLfh+8Hr8g+mf+7zVPEC8nEbqpdl3GPv3A7AwpFp7MA==" }]
  }
}

# Disks are encrypted with Google-managed keys by default.
resource "google_compute_disk" "fail_disk_google_managed" {
  expect_failure = true
  attrs = {
    name = "fail-disk-google-managed"
    zone = "us-central1-a"
    size = 10
  }
}

# A customer-managed (KMS) key is CMEK, not CSEK.
resource "google_compute_disk" "fail_disk_cmek_is_not_csek" {
  expect_failure = true
  attrs = {
    name                = "fail-disk-cmek-is-not-csek"
    zone                = "us-central1-a"
    size                = 10
    disk_encryption_key = [{ kms_key_self_link = "projects/example-project/locations/us-central1/keyRings/ring/cryptoKeys/key" }]
  }
}

resource "google_compute_region_disk" "pass_region_disk_raw_key" {
  attrs = {
    name                = "pass-region-disk-raw-key"
    region              = "us-central1"
    replica_zones       = ["us-central1-a", "us-central1-b"]
    size                = 10
    disk_encryption_key = [{ raw_key = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0=" }]
  }
}

resource "google_compute_region_disk" "fail_region_disk_google_managed" {
  expect_failure = true
  attrs = {
    name          = "fail-region-disk-google-managed"
    region        = "us-central1"
    replica_zones = ["us-central1-a", "us-central1-b"]
    size          = 10
  }
}

resource "google_compute_instance" "pass_instance_all_disks_csek" {
  attrs = {
    name         = "pass-instance-all-disks-csek"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params       = [{ image = "debian-cloud/debian-12" }]
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    attached_disk = [
      { source = "data-disk", disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0=" },
    ]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_instance_boot_disk_google_managed" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-boot-disk-google-managed"
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

resource "google_compute_instance" "fail_instance_boot_disk_cmek" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-boot-disk-cmek"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params = [{ image = "debian-cloud/debian-12" }]
      kms_key_self_link = "projects/example-project/locations/us-central1/keyRings/ring/cryptoKeys/key"
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_instance_attached_disk_without_csek" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-attached-disk-without-csek"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params       = [{ image = "debian-cloud/debian-12" }]
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    attached_disk = [
      { source = "data-disk-1", disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0=" },
      { source = "data-disk-2" },
    ]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance_from_template" "pass_from_template_disks_csek" {
  attrs = {
    name                     = "from-template-csek"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
    boot_disk = [{
      source                  = "boot-disk"
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    attached_disk = [{
      source                  = "data-disk"
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
  }
}

resource "google_compute_instance_from_template" "fail_from_template_template_disks" {
  expect_failure = true
  attrs = {
    name                     = "from-template-default-disks"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
  }
}

resource "google_compute_instance_from_template" "fail_from_template_attached_disk_without_csek" {
  expect_failure = true
  attrs = {
    name                     = "from-template-mixed"
    zone                     = "us-central1-a"
    source_instance_template = "projects/example-project/global/instanceTemplates/base"
    boot_disk = [{
      source                  = "boot-disk"
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    attached_disk = [{
      source = "data-disk"
    }]
  }
}

# An empty key is not a customer-supplied key.
resource "google_compute_disk" "fail_disk_empty_raw_key" {
  expect_failure = true
  attrs = {
    name                = "fail-disk-empty-raw-key"
    zone                = "us-central1-a"
    size                = 10
    disk_encryption_key = [{ raw_key = "" }]
  }
}

# Hyperdisk cannot use CSEK, so it is evaluated and fails.
resource "google_compute_disk" "fail_disk_hyperdisk_google_managed" {
  expect_failure = true
  attrs = {
    name = "fail-disk-hyperdisk-google-managed"
    zone = "us-central1-a"
    size = 10
    type = "hyperdisk-balanced"
  }
}

resource "google_compute_region_disk" "fail_region_disk_cmek_is_not_csek" {
  expect_failure = true
  attrs = {
    name                = "fail-region-disk-cmek-is-not-csek"
    region              = "us-central1"
    replica_zones       = ["us-central1-a", "us-central1-b"]
    size                = 10
    disk_encryption_key = [{ kms_key_name = "projects/example-project/locations/us-central1/keyRings/ring/cryptoKeys/key" }]
  }
}

resource "google_compute_instance" "fail_instance_boot_disk_empty_raw_key" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-boot-disk-empty-raw-key"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params       = [{ image = "debian-cloud/debian-12" }]
      disk_encryption_key_raw = ""
    }]
    network_interface = [{
      network = "default"
    }]
  }
}

resource "google_compute_instance" "fail_instance_attached_disk_cmek" {
  expect_failure = true
  attrs = {
    name         = "fail-instance-attached-disk-cmek"
    machine_type = "e2-micro"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params       = [{ image = "debian-cloud/debian-12" }]
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    attached_disk = [
      { source = "data-disk", kms_key_self_link = "projects/example-project/locations/us-central1/keyRings/ring/cryptoKeys/key" },
    ]
    network_interface = [{
      network = "default"
    }]
  }
}

# Local SSD scratch disks cannot use CSEK and are not evaluated.
resource "google_compute_instance" "pass_instance_csek_with_local_ssd" {
  attrs = {
    name         = "pass-instance-csek-with-local-ssd"
    machine_type = "n2-standard-2"
    zone         = "us-central1-a"
    boot_disk = [{
      initialize_params       = [{ image = "debian-cloud/debian-12" }]
      disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
    }]
    scratch_disk = [{ interface = "NVME" }]
    network_interface = [{
      network = "default"
    }]
  }
}
