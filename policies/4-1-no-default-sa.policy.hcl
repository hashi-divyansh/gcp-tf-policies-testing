# Copyright IBM Corp. 2026

# Ensure That Instances Are Not Configured To Use the Default Service Account

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_compute_instance" "no_default_service_account" {
  locals {
    service_accounts_raw = core::try(attrs.service_account, null)
    service_accounts     = local.service_accounts_raw != null ? local.service_accounts_raw : []
    has_service_account  = core::length(local.service_accounts) > 0
    email_raw            = core::try(local.service_accounts[0].email, null)
    email                = local.email_raw != null ? local.email_raw : ""
    has_email            = local.email != ""
    uses_default_account = core::endswith(local.email, "-compute@developer.gserviceaccount.com")
    is_compliant         = local.has_service_account && local.has_email && !local.uses_default_account
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.is_compliant
    error_message = "Compute Engine instances must explicitly use a non-default service account. Configure service_account.email with a custom service account address."
  }
}
