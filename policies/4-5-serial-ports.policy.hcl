# Copyright IBM Corp. 2026

# Ensure "Enable Connecting to Serial Ports" Is Not Enabled for VM Instance

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_compute_instance" "serial_port_access_disabled" {
  locals {
    metadata_raw           = core::try(attrs.metadata, null)
    metadata               = local.metadata_raw != null ? local.metadata_raw : {}
    serial_port_enable_raw = core::try(local.metadata["serial-port-enable"], null)
    # GCP metadata booleans are case-insensitive and accept several falsy
    # aliases (false, N, No, 0); match on the lowercased value.
    serial_port_disabled   = local.serial_port_enable_raw == null ? true : core::contains(["false", "n", "no", "0"], core::lower(local.serial_port_enable_raw))
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.serial_port_disabled
    error_message = "Compute Engine VM instances must omit metadata key 'serial-port-enable' or set it to a falsy value (false/N/No/0)."
  }
}
