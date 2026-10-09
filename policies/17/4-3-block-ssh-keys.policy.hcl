# Copyright IBM Corp. 2026

# Ensure "Block Project-Wide SSH Keys" Is Enabled for VM Instances

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "block-ssh-keys-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_instance" "block_project_wide_ssh_keys" {
  locals {
    metadata_raw               = core::try(attrs.metadata, null)
    metadata                   = local.metadata_raw != null ? local.metadata_raw : {}
    block_project_ssh_keys_raw = core::try(local.metadata["block-project-ssh-keys"], null)
    # GCP metadata booleans are case-insensitive with truthy aliases
    # (TRUE, Y, Yes, 1). The null guard must be a ternary: core::lower
    # errors on null and this DSL's && evaluates both operands.
    block_project_ssh_keys_set = local.block_project_ssh_keys_raw != null ? core::contains(["true", "y", "yes", "1"], core::lower(local.block_project_ssh_keys_raw)) : false
  }

  enforcement_level = input.block-ssh-keys-enforcement-level
  enforce {
    condition     = local.block_project_ssh_keys_set
    error_message = "Compute Engine instances must set metadata[\"block-project-ssh-keys\"] to a truthy value (true/TRUE/Y/Yes/1)."
  }
}
