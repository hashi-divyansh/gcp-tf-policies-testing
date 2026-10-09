# Copyright IBM Corp. 2026

# Ensure That IAM Users Are Not Assigned the Service Account User or Service Account Token Creator Roles at Project Level

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "project-iam-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_project_iam_binding" "deny_project_level_service_account_roles_for_users" {
  locals {
    prohibited_roles = [
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountTokenCreator",
    ]
    role_raw     = core::try(attrs.role, null)
    role         = local.role_raw != null ? local.role_raw : ""
    members_raw  = core::try(attrs.members, null)
    members      = local.members_raw != null ? local.members_raw : []
    user_members = [for member in local.members : member if core::startswith(member, "user:")]
    is_compliant = !core::contains(local.prohibited_roles, local.role) || core::length(local.user_members) == 0
  }

  enforcement_level = input.project-iam-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Do not grant Service Account User or Service Account Token Creator to users at project level; grant the role on the specific service account instead."
  }
}

resource_policy "google_project_iam_member" "deny_project_level_service_account_roles_for_users" {
  locals {
    prohibited_roles = [
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountTokenCreator",
    ]
    role_raw     = core::try(attrs.role, null)
    role         = local.role_raw != null ? local.role_raw : ""
    member_raw   = core::try(attrs.member, null)
    member       = local.member_raw != null ? local.member_raw : ""
    is_user      = core::startswith(local.member, "user:")
    is_compliant = !core::contains(local.prohibited_roles, local.role) || !local.is_user
  }

  enforcement_level = input.project-iam-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Do not grant Service Account User or Service Account Token Creator to users at project level; grant the role on the specific service account instead."
  }
}

# google_project_iam_policy is authoritative: it replaces the entire
# project IAM policy, so its bindings must be checked directly rather
# than through google_project_iam_binding/member.
resource_policy "google_project_iam_policy" "deny_project_level_service_account_roles_for_users" {
  locals {
    prohibited_roles = [
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountTokenCreator",
    ]
    policy_data_raw = core::try(attrs.policy_data, null)
    policy_doc      = core::try(core::jsondecode(core::try(local.policy_data_raw, "")), {})
    bindings_raw    = core::try(local.policy_doc.bindings, null)
    bindings        = local.bindings_raw != null ? local.bindings_raw : []
  }

  locals {
    normalized_bindings = [for binding in local.bindings : {
      role         = core::try(binding.role, "")
      members_safe = core::try(binding.members, null) != null ? binding.members : []
    }]
  }

  locals {
    violations = [
      for binding in local.normalized_bindings : binding
      if core::contains(local.prohibited_roles, binding.role) && core::length([for member in binding.members_safe : member if core::startswith(member, "user:")]) > 0
    ]
  }

  enforcement_level = input.project-iam-enforcement-level
  enforce {
    condition     = core::length(local.violations) == 0
    error_message = "Do not grant Service Account User or Service Account Token Creator to users at project level; grant the role on the specific service account instead."
  }
}
