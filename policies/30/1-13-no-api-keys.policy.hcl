# Copyright IBM Corp. 2026

# Ensure API Keys Only Exist for Active Services

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "no-api-keys-enforcement-level" {
  type    = string
  default = "advisory"
}

# Every API key is reported: whether it serves an active service is not visible in a plan.
resource_policy "google_apikeys_key" "api_keys_not_used" {
  locals {
    name_raw = core::try(attrs.name, null)
    name     = local.name_raw != null ? local.name_raw : ""
  }

  enforcement_level = input.no-api-keys-enforcement-level
  enforce {
    condition     = false
    error_message = "API key '${local.name}' should not exist. Use the standard authentication flow (service accounts or OAuth) instead, or delete keys that are not needed by an active service."
  }
}
