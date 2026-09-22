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

input "serial-ports-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  # Project-wide metadata (from either resource type) propagates to every
  # instance in the same project unless the instance sets its own
  # "serial-port-enable" key, which overrides the project-level value.
  project_metadata_resources      = core::getresources("google_compute_project_metadata", {})
  project_metadata_item_resources = core::getresources("google_compute_project_metadata_item", {})
}

resource_policy "google_compute_instance" "serial_port_access_disabled" {
  locals {
    metadata_raw           = core::try(attrs.metadata, null)
    metadata               = local.metadata_raw != null ? local.metadata_raw : {}
    serial_port_enable_raw = core::try(local.metadata["serial-port-enable"], null)
    # GCP metadata booleans are case-insensitive and accept several falsy
    # aliases (false, N, No, 0). The null guard must be a ternary:
    # core::lower errors on null and this DSL's && evaluates both operands.
    # Any explicitly-set, non-falsy value (including an unrecognized
    # string) counts as enabling serial port access, matching CIS intent.
    instance_key_disabled = local.serial_port_enable_raw == null ? false : core::contains(["false", "n", "no", "0"], core::lower(local.serial_port_enable_raw))

    instance_project_raw = core::try(attrs.project, null)
    instance_project     = local.instance_project_raw != null ? local.instance_project_raw : ""
  }

  locals {
    # google_compute_project_metadata carries a metadata map, while
    # google_compute_project_metadata_item carries a flat key/value pair.
    # Normalize both into a common shape before matching them on project.
    project_metadata_safe = [for r in local.project_metadata_resources : {
      project  = core::try(r.project, null) != null ? r.project : ""
      metadata = core::try(r.metadata, null) != null ? r.metadata : {}
    }]
    project_metadata_item_safe = [for r in local.project_metadata_item_resources : {
      project   = core::try(r.project, null) != null ? r.project : ""
      key       = core::try(r.key, null) != null ? r.key : ""
      value_raw = core::try(r.value, null)
    }]
  }

  locals {
    project_metadata_values = [for e in local.project_metadata_safe : {
      project   = e.project
      value_raw = core::try(e.metadata["serial-port-enable"], null)
    }]
  }

  locals {
    project_metadata_enables_serial_port = core::length([
      for e in local.project_metadata_values : e
      if e.project == local.instance_project && (e.value_raw == null ? false : !core::contains(["false", "n", "no", "0"], core::lower(e.value_raw)))
    ]) > 0

    project_metadata_item_enables_serial_port = core::length([
      for e in local.project_metadata_item_safe : e
      if e.project == local.instance_project && e.key == "serial-port-enable" && (e.value_raw == null ? false : !core::contains(["false", "n", "no", "0"], core::lower(e.value_raw)))
    ]) > 0

    project_serial_port_enabled = local.project_metadata_enables_serial_port || local.project_metadata_item_enables_serial_port

    # An explicit instance-level key overrides the project-wide value in
    # either direction; only an instance that omits the key inherits.
    serial_port_disabled = local.serial_port_enable_raw != null ? local.instance_key_disabled : !local.project_serial_port_enabled
  }

  enforcement_level = input.serial-ports-enforcement-level
  enforce {
    condition     = local.serial_port_disabled
    error_message = "Compute Engine VM instances must omit metadata key 'serial-port-enable' (or set it to a falsy value) and must not inherit a truthy value from project-wide metadata."
  }
}

resource_policy "google_compute_project_metadata" "project_serial_port_access_disabled" {
  locals {
    metadata_raw           = core::try(attrs.metadata, null)
    metadata               = local.metadata_raw != null ? local.metadata_raw : {}
    serial_port_enable_raw = core::try(local.metadata["serial-port-enable"], null)
    serial_port_disabled   = local.serial_port_enable_raw == null ? true : core::contains(["false", "n", "no", "0"], core::lower(local.serial_port_enable_raw))
  }

  enforcement_level = input.serial-ports-enforcement-level
  enforce {
    condition     = local.serial_port_disabled
    error_message = "Project-wide compute metadata must omit key 'serial-port-enable' or set it to a falsy value (false/N/No/0); it propagates to every instance in the project."
  }
}

resource_policy "google_compute_project_metadata_item" "project_serial_port_item_disabled" {
  filter = core::try(attrs.key, "") == "serial-port-enable"

  locals {
    value_raw     = core::try(attrs.value, null)
    value_falsy   = local.value_raw == null ? true : core::contains(["false", "n", "no", "0"], core::lower(local.value_raw))
  }

  enforcement_level = input.serial-ports-enforcement-level
  enforce {
    condition     = local.value_falsy
    error_message = "The project-wide 'serial-port-enable' metadata item must be set to a falsy value (false/N/No/0); it propagates to every instance in the project."
  }
}
