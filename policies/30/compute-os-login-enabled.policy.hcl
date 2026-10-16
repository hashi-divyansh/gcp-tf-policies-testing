# Copyright IBM Corp. 2026

# Ensure Oslogin Is Enabled for a Project

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "compute-os-login-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  # Only values the guest agent parses as true (Go strconv.ParseBool); Y/Yes do not
  # enable OS Login. Matched exactly, unlike the case-insensitive 4-3 and 4-5 policies.
  oslogin_truthy_values = ["1", "t", "T", "true", "True", "TRUE"]

  oslogin_project_settings = core::concat(
    [
      for metadata in core::getresources("google_compute_project_metadata", {}) : {
        project = core::try(metadata.project, null)
        value   = core::try(metadata.metadata["enable-oslogin"], null)
      }
    ],
    [
      for item in core::getresources("google_compute_project_metadata_item", {}) : {
        project = core::try(item.project, null)
        value   = core::try(item.value, null)
      } if core::try(item.key, null) == "enable-oslogin"
    ]
  )
}

resource_policy "google_project" "new_project_oslogin_enabled" {
  operations = ["create"]

  locals {
    project_id_raw = core::try(attrs.project_id, null)
    project_id     = local.project_id_raw != null ? local.project_id_raw : ""
    own_settings = [
      for setting in local.oslogin_project_settings : setting
      if local.project_id != "" && setting.project == local.project_id
    ]
    disabled_settings = [
      for setting in local.own_settings : setting
      if !core::contains(local.oslogin_truthy_values, setting.value != null ? setting.value : "")
    ]
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = core::length(local.own_settings) > 0 && core::length(local.disabled_settings) == 0
    error_message = "New projects must enable OS Login through matching google_compute_project_metadata or google_compute_project_metadata_item resources. Set project to this project's project_id and enable-oslogin to TRUE."
  }
}

# An unset enable-oslogin is treated as FALSE.
resource_policy "google_compute_project_metadata" "project_oslogin_enabled" {
  locals {
    metadata_raw = core::try(attrs.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : {}
    value_raw    = core::try(local.metadata["enable-oslogin"], null)
    enabled      = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : false
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.enabled
    error_message = "Project-wide compute metadata must set 'enable-oslogin' to TRUE."
  }
}

resource_policy "google_compute_project_metadata_item" "project_oslogin_item_enabled" {
  filter = core::try(attrs.key, "") == "enable-oslogin"

  locals {
    value_raw = core::try(attrs.value, null)
    enabled   = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : false
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.enabled
    error_message = "The project-wide 'enable-oslogin' metadata item must be set to TRUE."
  }
}

# Instances may omit enable-oslogin to inherit the project value, but must not disable it.
resource_policy "google_compute_instance" "instance_oslogin_not_disabled" {
  locals {
    metadata_raw = core::try(attrs.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : {}
    value_raw    = core::try(local.metadata["enable-oslogin"], null)
    not_disabled = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : true
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.not_disabled
    error_message = "Compute instances must not override 'enable-oslogin' in metadata with a non-TRUE value. Remove the key or set it to TRUE."
  }
}

resource_policy "google_compute_instance_from_template" "instance_from_template_oslogin_not_disabled" {
  locals {
    metadata_raw = core::try(attrs.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : {}
    value_raw    = core::try(local.metadata["enable-oslogin"], null)
    not_disabled = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : true
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.not_disabled
    error_message = "Compute instances must not override 'enable-oslogin' in metadata with a non-TRUE value. Remove the key or set it to TRUE."
  }
}

resource_policy "google_compute_instance_template" "instance_template_oslogin_not_disabled" {
  locals {
    metadata_raw = core::try(attrs.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : {}
    value_raw    = core::try(local.metadata["enable-oslogin"], null)
    not_disabled = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : true
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.not_disabled
    error_message = "Instance templates must not set 'enable-oslogin' in metadata to a non-TRUE value. Remove the key or set it to TRUE."
  }
}

resource_policy "google_compute_region_instance_template" "region_instance_template_oslogin_not_disabled" {
  locals {
    metadata_raw = core::try(attrs.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : {}
    value_raw    = core::try(local.metadata["enable-oslogin"], null)
    not_disabled = local.value_raw != null ? core::contains(local.oslogin_truthy_values, local.value_raw) : true
  }

  enforcement_level = input.compute-os-login-enabled-enforcement-level
  enforce {
    condition     = local.not_disabled
    error_message = "Instance templates must not set 'enable-oslogin' in metadata to a non-TRUE value. Remove the key or set it to TRUE."
  }
}
