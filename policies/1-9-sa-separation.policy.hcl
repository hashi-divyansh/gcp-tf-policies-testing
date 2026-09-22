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

input "sa-separation-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  service_account_admin_role = "roles/iam.serviceAccountAdmin"
  service_account_user_role  = "roles/iam.serviceAccountUser"
  separation_roles           = [local.service_account_admin_role, local.service_account_user_role]
  project_iam_bindings       = core::getresources("google_project_iam_binding", {})
  project_iam_members        = core::getresources("google_project_iam_member", {})
  project_iam_policies       = core::getresources("google_project_iam_policy", {})
}

locals {
  # Decode every google_project_iam_policy's policy_data once, so its
  # (project, role, members) grants can be cross-checked from the
  # binding/member resource_policies below as well.
  project_iam_policy_docs = [for p in local.project_iam_policies : {
    project    = core::try(p.project, "")
    policy_raw = core::try(p.policy_data, null)
  }]
}

locals {
  project_iam_policy_parsed = [for d in local.project_iam_policy_docs : {
    project = d.project
    doc     = core::try(core::jsondecode(core::try(d.policy_raw, "")), {})
  }]
}

locals {
  project_iam_policy_bindings = [for d in local.project_iam_policy_parsed : {
    project  = d.project
    bindings = core::try(d.doc.bindings, null) != null ? d.doc.bindings : []
  }]
}

locals {
  project_iam_policy_grants = core::flatten([
    for d in local.project_iam_policy_bindings : [
      for binding in d.bindings : {
        project = d.project
        role    = core::try(binding.role, "")
        members = core::try(binding.members, null) != null ? binding.members : []
      }
    ]
  ])
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
    conflicts = [for user in local.user_members : user if core::length([for binding in local.project_iam_bindings : binding if core::try(binding.project, "") == local.project && core::try(binding.role, "") == local.opposite_role && core::contains(core::try(binding.members, null) != null ? binding.members : [], user)]) > 0 || core::length([for member in local.project_iam_members : member if core::try(member.project, "") == local.project && core::try(member.role, "") == local.opposite_role && core::try(member.member, "") == user]) > 0 || core::length([for grant in local.project_iam_policy_grants : grant if grant.project == local.project && grant.role == local.opposite_role && core::contains(grant.members, user)]) > 0]
  }

  enforcement_level = input.sa-separation-enforcement-level
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
    binding_conflicts = [for binding in local.project_iam_bindings : binding if core::try(binding.project, "") == local.project && core::try(binding.role, "") == local.opposite_role && core::contains(core::try(binding.members, null) != null ? binding.members : [], local.user)]
    member_conflicts  = [for member in local.project_iam_members : member if core::try(member.project, "") == local.project && core::try(member.role, "") == local.opposite_role && core::try(member.member, "") == local.user]
    policy_conflicts  = [for grant in local.project_iam_policy_grants : grant if grant.project == local.project && grant.role == local.opposite_role && core::contains(grant.members, local.user)]
  }

  enforcement_level = input.sa-separation-enforcement-level
  enforce {
    condition     = core::length(local.binding_conflicts) == 0 && core::length(local.member_conflicts) == 0 && core::length(local.policy_conflicts) == 0
    error_message = "A user must not receive both roles/iam.serviceAccountAdmin and roles/iam.serviceAccountUser in the same project. Remove one of the conflicting role grants."
  }
}

# google_project_iam_policy is authoritative: it replaces the entire
# project IAM policy, so its bindings must be checked directly rather
# than through google_project_iam_binding/member.
# Both conflicting roles can appear in a single policy_data document, so
# these grants are also cross-checked against binding and member
# resources for the same project.
resource_policy "google_project_iam_policy" "enforce_service_account_role_separation" {
  locals {
    project         = core::try(attrs.project, "")
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
    admin_users = [
      for binding in local.normalized_bindings : binding.members_safe
      if binding.role == local.service_account_admin_role
    ]
    user_role_users = [
      for binding in local.normalized_bindings : binding.members_safe
      if binding.role == local.service_account_user_role
    ]
  }

  locals {
    # Flatten the (possibly multiple) matching bindings into single lists
    # of "user:" members granted each role within this same policy_data.
    admin_user_members = core::distinct(core::flatten([
      for members in local.admin_users : [for member in members : member if core::startswith(member, "user:")]
    ]))
    user_role_user_members = core::distinct(core::flatten([
      for members in local.user_role_users : [for member in members : member if core::startswith(member, "user:")]
    ]))
    self_conflicts = [for user in local.admin_user_members : user if core::contains(local.user_role_user_members, user)]

    cross_binding_conflicts = [
      for user in core::concat(local.admin_user_members, local.user_role_user_members) : user
      if core::length([
        for binding in local.project_iam_bindings : binding
        if core::try(binding.project, "") == local.project
        && (
          (core::try(binding.role, "") == local.service_account_user_role && core::contains(local.admin_user_members, user)) ||
          (core::try(binding.role, "") == local.service_account_admin_role && core::contains(local.user_role_user_members, user))
        )
        && core::contains(core::try(binding.members, null) != null ? binding.members : [], user)
      ]) > 0
    ]
    cross_member_conflicts = [
      for user in core::concat(local.admin_user_members, local.user_role_user_members) : user
      if core::length([
        for member in local.project_iam_members : member
        if core::try(member.project, "") == local.project
        && (
          (core::try(member.role, "") == local.service_account_user_role && core::contains(local.admin_user_members, user)) ||
          (core::try(member.role, "") == local.service_account_admin_role && core::contains(local.user_role_user_members, user))
        )
        && core::try(member.member, "") == user
      ]) > 0
    ]

    has_conflict = core::length(local.self_conflicts) > 0 || core::length(local.cross_binding_conflicts) > 0 || core::length(local.cross_member_conflicts) > 0
  }

  enforcement_level = input.sa-separation-enforcement-level
  enforce {
    condition     = !local.has_conflict
    error_message = "A user must not receive both roles/iam.serviceAccountAdmin and roles/iam.serviceAccountUser in the same project. Remove one of the conflicting role grants."
  }
}
