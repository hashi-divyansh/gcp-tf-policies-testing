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

input "sa-no-admin-enforcement-level" {
  type    = string
  default = "advisory"
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

  enforcement_level = input.sa-no-admin-enforcement-level
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

  enforcement_level = input.sa-no-admin-enforcement-level
  enforce {
    condition     = !local.service_account || !local.prohibited_role
    error_message = "Remove Owner, Editor, and roles containing Admin or admin from service accounts; grant a least-privilege role instead."
  }
}

# google_project_iam_policy is authoritative: it replaces the entire
# project IAM policy, so its bindings must be checked directly rather
# than through google_project_iam_binding/member.
resource_policy "google_project_iam_policy" "service_accounts_must_not_have_admin_privileges" {
  locals {
    policy_data_raw = core::try(attrs.policy_data, null)
    policy_doc      = core::try(core::jsondecode(core::try(local.policy_data_raw, "")), {})
    bindings_raw    = core::try(local.policy_doc.bindings, null)
    bindings        = local.bindings_raw != null ? local.bindings_raw : []
  }

  locals {
    # Normalize each binding into a safe (role, members) tuple before
    # checking it, so no downstream expression operates on a null value.
    normalized_bindings = [for binding in local.bindings : {
      role         = core::try(binding.role, "")
      members_safe = core::try(binding.members, null) != null ? binding.members : []
    }]
  }

  locals {
    violations = [
      for binding in local.normalized_bindings : binding
      if (
        binding.role == "roles/editor" ||
        binding.role == "roles/owner" ||
        core::contains_substring(binding.role, "Admin") ||
        core::contains_substring(binding.role, "admin")
      ) && core::length([for member in binding.members_safe : member if core::startswith(member, "serviceAccount:")]) > 0
    ]
  }

  enforcement_level = input.sa-no-admin-enforcement-level
  enforce {
    condition     = core::length(local.violations) == 0
    error_message = "Remove Owner, Editor, and roles containing Admin or admin from service accounts; grant a least-privilege role instead."
  }
}
