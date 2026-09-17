# Copyright IBM Corp. 2026

# Ensure That Service Account Has No Admin Privileges

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_project_iam_binding" "service_accounts_must_not_have_admin_privileges" {
  locals {
    role_raw                = core::try(attrs.role, null)
    role                    = local.role_raw != null ? local.role_raw : ""
    members_raw             = core::try(attrs.members, null)
    members                 = local.members_raw != null ? local.members_raw : []
    service_account_members = [for member in local.members : member if core::startswith(member, "serviceAccount:")]
    prohibited_role         = local.role == "roles/editor" || local.role == "roles/owner" || core::contains_substring(local.role, "Admin") || core::contains_substring(local.role, "admin")
  }

  enforcement_level = "advisory"
  enforce {
    condition     = core::length(local.service_account_members) == 0 || !local.prohibited_role
    error_message = "Remove Owner, Editor, and roles containing Admin or admin from service accounts; grant a least-privilege role instead."
  }
}

resource_policy "google_project_iam_member" "service_accounts_must_not_have_admin_privileges" {
  locals {
    role_raw        = core::try(attrs.role, null)
    role            = local.role_raw != null ? local.role_raw : ""
    member_raw      = core::try(attrs.member, null)
    member          = local.member_raw != null ? local.member_raw : ""
    service_account = core::startswith(local.member, "serviceAccount:")
    prohibited_role = local.role == "roles/editor" || local.role == "roles/owner" || core::contains_substring(local.role, "Admin") || core::contains_substring(local.role, "admin")
  }

  enforcement_level = "advisory"
  enforce {
    condition     = !local.service_account || !local.prohibited_role
    error_message = "Remove Owner, Editor, and roles containing Admin or admin from service accounts; grant a least-privilege role instead."
  }
}
