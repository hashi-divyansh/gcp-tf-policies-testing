# Copyright IBM Corp. 2026

# Ensure That Separation of Duties Is Enforced While Assigning Service Account Related Roles to Users

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

locals {
  service_account_admin_role = "roles/iam.serviceAccountAdmin"
  service_account_user_role  = "roles/iam.serviceAccountUser"
  separation_roles           = [local.service_account_admin_role, local.service_account_user_role]
  project_iam_bindings       = core::getresources("google_project_iam_binding", {})
  project_iam_members        = core::getresources("google_project_iam_member", {})
}

resource_policy "google_project_iam_binding" "enforce_service_account_role_separation" {
  filter = core::contains(local.separation_roles, core::try(attrs.role, ""))

  locals {
    project       = core::try(attrs.project, "")
    role          = core::try(attrs.role, "")
    members_raw   = core::try(attrs.members, null)
    members       = local.members_raw != null ? local.members_raw : []
    user_members  = [for member in local.members : member if core::startswith(member, "user:")]
    opposite_role = local.role == local.service_account_admin_role ? local.service_account_user_role : local.service_account_admin_role
    conflicts = [for user in local.user_members : user if core::length([for binding in local.project_iam_bindings : binding if core::try(binding.project, "") == local.project && core::try(binding.role, "") == local.opposite_role && core::contains(core::try(binding.members, []), user)]) > 0 || core::length([for member in local.project_iam_members : member if core::try(member.project, "") == local.project && core::try(member.role, "") == local.opposite_role && core::try(member.member, "") == user]) > 0]
  }

  enforcement_level = "advisory"
  enforce {
    condition     = core::length(local.conflicts) == 0
    error_message = "A user must not receive both roles/iam.serviceAccountAdmin and roles/iam.serviceAccountUser in the same project. Remove one of the conflicting role grants."
  }
}

resource_policy "google_project_iam_member" "enforce_service_account_role_separation" {
  filter = core::contains(local.separation_roles, core::try(attrs.role, "")) && core::startswith(core::try(attrs.member, ""), "user:")

  locals {
    project       = core::try(attrs.project, "")
    role          = core::try(attrs.role, "")
    user          = core::try(attrs.member, "")
    opposite_role = local.role == local.service_account_admin_role ? local.service_account_user_role : local.service_account_admin_role
    binding_conflicts = [for binding in local.project_iam_bindings : binding if core::try(binding.project, "") == local.project && core::try(binding.role, "") == local.opposite_role && core::contains(core::try(binding.members, []), local.user)]
    member_conflicts  = [for member in local.project_iam_members : member if core::try(member.project, "") == local.project && core::try(member.role, "") == local.opposite_role && core::try(member.member, "") == local.user]
  }

  enforcement_level = "advisory"
  enforce {
    condition     = core::length(local.binding_conflicts) == 0 && core::length(local.member_conflicts) == 0
    error_message = "A user must not receive both roles/iam.serviceAccountAdmin and roles/iam.serviceAccountUser in the same project. Remove one of the conflicting role grants."
  }
}
