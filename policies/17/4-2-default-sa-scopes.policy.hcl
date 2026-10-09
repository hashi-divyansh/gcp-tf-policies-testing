# Copyright IBM Corp. 2026

# Ensure That Instances Are Not Configured To Use the Default Service Account With Full Access to All Cloud APIs

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "default-sa-scopes-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_instance" "default_service_account_scopes" {
  locals {
    service_account_raw = core::try(attrs.service_account[0], attrs.service_account, null)
    has_service_account = local.service_account_raw != null
    email_raw           = core::try(local.service_account_raw.email, null)
    email               = local.email_raw != null ? local.email_raw : ""
    scopes_raw          = core::try(local.service_account_raw.scopes, null)
    scopes              = local.scopes_raw != null ? local.scopes_raw : []

    uses_implicit_default = local.has_service_account && local.email == ""
    uses_named_default    = core::try(core::regex("^[0-9]+-compute@developer[.]gserviceaccount[.]com$", local.email), null) != null
    uses_default_account  = local.uses_implicit_default || local.uses_named_default
    has_full_access       = core::contains(local.scopes, "cloud-platform") || core::contains(local.scopes, "https://www.googleapis.com/auth/cloud-platform")
    is_compliant          = !(local.uses_default_account && local.has_full_access)
  }

  enforcement_level = input.default-sa-scopes-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Compute Engine instances must use a non-default service account or remove the cloud-platform OAuth scope."
  }
}
