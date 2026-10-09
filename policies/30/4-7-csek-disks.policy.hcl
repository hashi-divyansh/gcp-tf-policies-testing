# Copyright IBM Corp. 2026

# Ensure VM Disks for Critical VMs Are Encrypted With Customer-Supplied Encryption Keys (CSEK)

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "csek-disks-enforcement-level" {
  type    = string
  default = "advisory"
}

# Optional label key that limits the policy to critical resources ("" = all).
input "csek-disks-critical-label-key" {
  type    = string
  default = ""
}

# CMEK does not satisfy this control. Google deprecated CSEK for new disks on 2026-07-20;
# this policy follows CIS v5.0.0 as written. Instance templates cannot hold CSEKs.
resource_policy "google_compute_disk" "disk_encrypted_with_csek" {
  locals {
    labels_raw           = core::try(attrs.labels, null)
    labels               = local.labels_raw != null ? local.labels_raw : {}
    terraform_labels_raw = core::try(attrs.terraform_labels, null)
    terraform_labels     = local.terraform_labels_raw != null ? local.terraform_labels_raw : {}
    in_scope             = input.csek-disks-critical-label-key == "" ? true : core::contains(core::concat(core::keys(local.labels), core::keys(local.terraform_labels)), input.csek-disks-critical-label-key)
    raw_key_raw          = core::try(attrs.disk_encryption_key[0].raw_key, null)
    rsa_key_raw          = core::try(attrs.disk_encryption_key[0].rsa_encrypted_key, null)
    has_csek             = (local.raw_key_raw != null ? local.raw_key_raw != "" : false) || (local.rsa_key_raw != null ? local.rsa_key_raw != "" : false)
  }

  filter = local.in_scope

  enforcement_level = input.csek-disks-enforcement-level
  enforce {
    condition     = local.has_csek
    error_message = "Compute disks must be encrypted with a customer-supplied encryption key: set disk_encryption_key.raw_key or disk_encryption_key.rsa_encrypted_key."
  }
}

resource_policy "google_compute_region_disk" "region_disk_encrypted_with_csek" {
  locals {
    labels_raw           = core::try(attrs.labels, null)
    labels               = local.labels_raw != null ? local.labels_raw : {}
    terraform_labels_raw = core::try(attrs.terraform_labels, null)
    terraform_labels     = local.terraform_labels_raw != null ? local.terraform_labels_raw : {}
    in_scope             = input.csek-disks-critical-label-key == "" ? true : core::contains(core::concat(core::keys(local.labels), core::keys(local.terraform_labels)), input.csek-disks-critical-label-key)
    raw_key_raw          = core::try(attrs.disk_encryption_key[0].raw_key, null)
    # rsa_encrypted_key is only available on regional disks in provider v7.
    rsa_key_raw          = core::try(attrs.disk_encryption_key[0].rsa_encrypted_key, null)
    has_csek             = (local.raw_key_raw != null ? local.raw_key_raw != "" : false) || (local.rsa_key_raw != null ? local.rsa_key_raw != "" : false)
  }

  filter = local.in_scope

  enforcement_level = input.csek-disks-enforcement-level
  enforce {
    condition     = local.has_csek
    error_message = "Regional compute disks must be encrypted with a customer-supplied encryption key: set disk_encryption_key.raw_key (or rsa_encrypted_key)."
  }
}

resource_policy "google_compute_instance" "instance_disks_encrypted_with_csek" {
  locals {
    labels_raw           = core::try(attrs.labels, null)
    labels               = local.labels_raw != null ? local.labels_raw : {}
    terraform_labels_raw = core::try(attrs.terraform_labels, null)
    terraform_labels     = local.terraform_labels_raw != null ? local.terraform_labels_raw : {}
    in_scope             = input.csek-disks-critical-label-key == "" ? true : core::contains(core::concat(core::keys(local.labels), core::keys(local.terraform_labels)), input.csek-disks-critical-label-key)

    # Test lengths: try() is unknown for partially-unknown blocks.
    boot_disks     = core::try(core::length(attrs.boot_disk), 0) > 0 ? attrs.boot_disk : []
    attached_disks = core::try(core::length(attrs.attached_disk), 0) > 0 ? attrs.attached_disk : []
    # disk_encryption_key_rsa is only available on instances in provider v7.
    disks_without_csek = [
      for disk in core::concat(local.boot_disks, local.attached_disks) : disk
      if !((core::try(disk.disk_encryption_key_raw, null) != null ? disk.disk_encryption_key_raw != "" : false) || (core::try(disk.disk_encryption_key_rsa, null) != null ? disk.disk_encryption_key_rsa != "" : false))
    ]
  }

  filter = local.in_scope

  enforcement_level = input.csek-disks-enforcement-level
  enforce {
    condition     = core::length(local.boot_disks) > 0 && core::length(local.disks_without_csek) == 0
    error_message = "Compute instances must use customer-supplied encryption keys on the boot disk and every attached disk: set disk_encryption_key_raw (or disk_encryption_key_rsa)."
  }
}

resource_policy "google_compute_instance_from_template" "instance_from_template_disks_encrypted_with_csek" {
  locals {
    labels_raw           = core::try(attrs.labels, null)
    labels               = local.labels_raw != null ? local.labels_raw : {}
    terraform_labels_raw = core::try(attrs.terraform_labels, null)
    terraform_labels     = local.terraform_labels_raw != null ? local.terraform_labels_raw : {}
    in_scope             = input.csek-disks-critical-label-key == "" ? true : core::contains(core::concat(core::keys(local.labels), core::keys(local.terraform_labels)), input.csek-disks-critical-label-key)

    # Test lengths: try() is unknown for partially-unknown blocks.
    boot_disks     = core::try(core::length(attrs.boot_disk), 0) > 0 ? attrs.boot_disk : []
    attached_disks = core::try(core::length(attrs.attached_disk), 0) > 0 ? attrs.attached_disk : []
    # Template disks are not CSEK, so keys must be supplied here. disk_encryption_key_rsa is v7 only.
    disks_without_csek = [
      for disk in core::concat(local.boot_disks, local.attached_disks) : disk
      if !((core::try(disk.disk_encryption_key_raw, null) != null ? disk.disk_encryption_key_raw != "" : false) || (core::try(disk.disk_encryption_key_rsa, null) != null ? disk.disk_encryption_key_rsa != "" : false))
    ]
  }

  filter = local.in_scope

  enforcement_level = input.csek-disks-enforcement-level
  enforce {
    condition     = core::length(local.boot_disks) > 0 && core::length(local.disks_without_csek) == 0
    error_message = "Compute instances created from templates must use customer-supplied encryption keys on the boot disk and every attached disk: set disk_encryption_key_raw (or disk_encryption_key_rsa)."
  }
}
