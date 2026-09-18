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
    # aliases (false, N, No, 0); the ternary below avoids calling
    # core::lower on a null value. Any explicitly-set, non-falsy value
    # (including unrecognized strings) is conservatively treated as
    # enabling serial port access, matching CIS control intent.
    instance_key_disabled = local.serial_port_enable_raw == null ? false : core::contains(["false", "n", "no", "0"], core::lower(local.serial_port_enable_raw))

    instance_project_raw = core::try(attrs.project, null)
    instance_project     = local.instance_project_raw != null ? local.instance_project_raw : ""
  }

  locals {
    # Normalize both project-metadata resource types into safe (project, key,
    # value) tuples before evaluating them, so no step calls core::lower on a
    # potentially null value.
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
    # Project-wide metadata (from either resource type, scoped to the same
    # project as this instance) propagates to every instance that omits its
    # own "serial-port-enable" key; an explicit instance-level value
    # overrides the inherited project-level value. Any explicitly-set,
    # non-falsy project-level value is conservatively treated as enabling,
    # matching the instance-level semantics above.
    project_metadata_enables_serial_port = core::length([
      for e in local.project_metadata_values : e
      if e.project == local.instance_project && (e.value_raw == null ? false : !core::contains(["false", "n", "no", "0"], core::lower(e.value_raw)))
    ]) > 0

    project_metadata_item_enables_serial_port = core::length([
      for e in local.project_metadata_item_safe : e
      if e.project == local.instance_project && e.key == "serial-port-enable" && (e.value_raw == null ? false : !core::contains(["false", "n", "no", "0"], core::lower(e.value_raw)))
    ]) > 0

    project_serial_port_enabled = local.project_metadata_enables_serial_port || local.project_metadata_item_enables_serial_port

    # If the instance sets its own key, that value alone decides the
    # outcome (an explicit value overrides project-level inheritance,
    # whichever direction it goes). Otherwise, inherit the project-wide
    # value.
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
