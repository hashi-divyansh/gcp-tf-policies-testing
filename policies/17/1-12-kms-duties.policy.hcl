# Copyright IBM Corp. 2026

# Ensure That Separation of Duties Is Enforced While Assigning KMS Related Roles to Users

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "kms-duties-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  kms_admin_role = "roles/cloudkms.admin"
  kms_crypto_roles = [
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudkms.cryptoKeyDecrypter",
  ]
  all_project_iam_bindings = core::getresources("google_project_iam_binding", {})
  all_project_iam_members  = core::getresources("google_project_iam_member", {})
  all_project_iam_policies = core::getresources("google_project_iam_policy", {})
}

locals {
  # Decode every google_project_iam_policy's policy_data once, so its
  # (project, role, members) grants can be cross-checked from the
  # binding/member resource_policies below as well.
  kms_project_iam_policy_docs = [for p in local.all_project_iam_policies : {
    project    = core::try(p.project, "")
    policy_raw = core::try(p.policy_data, null)
  }]
}

locals {
  kms_project_iam_policy_parsed = [for d in local.kms_project_iam_policy_docs : {
    project = d.project
    doc     = core::try(core::jsondecode(core::try(d.policy_raw, "")), {})
  }]
}

locals {
  kms_project_iam_policy_bindings = [for d in local.kms_project_iam_policy_parsed : {
    project  = d.project
    bindings = core::try(d.doc.bindings, null) != null ? d.doc.bindings : []
  }]
}

locals {
  kms_project_iam_policy_grants = core::flatten([
    for d in local.kms_project_iam_policy_bindings : [
      for binding in d.bindings : {
        project = d.project
        role    = core::try(binding.role, "")
        members = core::try(binding.members, null) != null ? binding.members : []
      }
    ]
  ])
}

resource_policy "google_project_iam_binding" "enforce_kms_separation_of_duties" {
  locals {
    project_raw = core::try(attrs.project, null)
    project     = local.project_raw != null ? local.project_raw : ""
    role_raw    = core::try(attrs.role, null)
    role        = local.role_raw != null ? local.role_raw : ""
    members_raw = core::try(attrs.members, null)
    members     = local.members_raw != null ? local.members_raw : []
    users       = [for member in local.members : member if core::startswith(member, "user:")]
    is_admin    = local.role == local.kms_admin_role
    is_crypto   = core::contains(local.kms_crypto_roles, local.role)
    counterpart_roles = local.is_admin ? local.kms_crypto_roles : [
      local.kms_admin_role,
    ]
    conflicts_in_bindings = [for user in local.users : user if core::length([
      for binding in local.all_project_iam_bindings : binding
      if core::try(binding.project, "") == local.project && core::contains(local.counterpart_roles, core::try(binding.role, "")) && core::contains(core::try(binding.members, null) != null ? binding.members : [], user)
    ]) > 0]
    conflicts_in_members = [for user in local.users : user if core::length([
      for member_grant in local.all_project_iam_members : member_grant
      if core::try(member_grant.project, "") == local.project && core::contains(local.counterpart_roles, core::try(member_grant.role, "")) && core::try(member_grant.member, "") == user
    ]) > 0]
    conflicts_in_policies = [for user in local.users : user if core::length([
      for grant in local.kms_project_iam_policy_grants : grant
      if grant.project == local.project && core::contains(local.counterpart_roles, grant.role) && core::contains(grant.members, user)
    ]) > 0]
    has_conflict = core::length(local.conflicts_in_bindings) > 0 || core::length(local.conflicts_in_members) > 0 || core::length(local.conflicts_in_policies) > 0
  }

  enforcement_level = input.kms-duties-enforcement-level
  enforce {
    condition     = !(local.is_admin || local.is_crypto) || !local.has_conflict
    error_message = "Remove either the Cloud KMS Admin role or the conflicting Cloud KMS cryptographic role from the user in this project to enforce separation of duties."
  }
}

resource_policy "google_project_iam_member" "enforce_kms_separation_of_duties" {
  locals {
    project_raw = core::try(attrs.project, null)
    project     = local.project_raw != null ? local.project_raw : ""
    role_raw    = core::try(attrs.role, null)
    role        = local.role_raw != null ? local.role_raw : ""
    member_raw  = core::try(attrs.member, null)
    member      = local.member_raw != null ? local.member_raw : ""
    is_user     = core::startswith(local.member, "user:")
    is_admin    = local.role == local.kms_admin_role
    is_crypto   = core::contains(local.kms_crypto_roles, local.role)
    counterpart_roles = local.is_admin ? local.kms_crypto_roles : [
      local.kms_admin_role,
    ]
    conflicts_in_bindings = [for binding in local.all_project_iam_bindings : binding
      if core::try(binding.project, "") == local.project && core::contains(local.counterpart_roles, core::try(binding.role, "")) && core::contains(core::try(binding.members, null) != null ? binding.members : [], local.member)]
    conflicts_in_members = [for member_grant in local.all_project_iam_members : member_grant
      if core::try(member_grant.project, "") == local.project && core::contains(local.counterpart_roles, core::try(member_grant.role, "")) && core::try(member_grant.member, "") == local.member]
    conflicts_in_policies = [for grant in local.kms_project_iam_policy_grants : grant
      if grant.project == local.project && core::contains(local.counterpart_roles, grant.role) && core::contains(grant.members, local.member)]
    has_conflict = core::length(local.conflicts_in_bindings) > 0 || core::length(local.conflicts_in_members) > 0 || core::length(local.conflicts_in_policies) > 0
  }

  enforcement_level = input.kms-duties-enforcement-level
  enforce {
    condition     = !local.is_user || !(local.is_admin || local.is_crypto) || !local.has_conflict
    error_message = "Remove either the Cloud KMS Admin role or the conflicting Cloud KMS cryptographic role from the user in this project to enforce separation of duties."
  }
}

# google_project_iam_policy is authoritative: it replaces the entire
# project IAM policy, so its bindings must be checked directly rather
# than through google_project_iam_binding/member.
# The Admin role and a conflicting crypto role can appear in a single
# policy_data document, so these grants are also cross-checked against
# binding and member resources for the same project.
resource_policy "google_project_iam_policy" "enforce_kms_separation_of_duties" {
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
    admin_users_raw = [
      for binding in local.normalized_bindings : binding.members_safe
      if binding.role == local.kms_admin_role
    ]
    crypto_users_raw = [
      for binding in local.normalized_bindings : binding.members_safe
      if core::contains(local.kms_crypto_roles, binding.role)
    ]
  }

  locals {
    admin_users = core::distinct(core::flatten([
      for members in local.admin_users_raw : [for member in members : member if core::startswith(member, "user:")]
    ]))
    crypto_users = core::distinct(core::flatten([
      for members in local.crypto_users_raw : [for member in members : member if core::startswith(member, "user:")]
    ]))
    self_conflicts = [for user in local.admin_users : user if core::contains(local.crypto_users, user)]

    cross_binding_conflicts = [
      for user in core::concat(local.admin_users, local.crypto_users) : user
      if core::length([
        for binding in local.all_project_iam_bindings : binding
        if core::try(binding.project, "") == local.project
        && (
          (core::contains(local.kms_crypto_roles, core::try(binding.role, "")) && core::contains(local.admin_users, user)) ||
          (core::try(binding.role, "") == local.kms_admin_role && core::contains(local.crypto_users, user))
        )
        && core::contains(core::try(binding.members, null) != null ? binding.members : [], user)
      ]) > 0
    ]
    cross_member_conflicts = [
      for user in core::concat(local.admin_users, local.crypto_users) : user
      if core::length([
        for member_grant in local.all_project_iam_members : member_grant
        if core::try(member_grant.project, "") == local.project
        && (
          (core::contains(local.kms_crypto_roles, core::try(member_grant.role, "")) && core::contains(local.admin_users, user)) ||
          (core::try(member_grant.role, "") == local.kms_admin_role && core::contains(local.crypto_users, user))
        )
        && core::try(member_grant.member, "") == user
      ]) > 0
    ]

    has_conflict = core::length(local.self_conflicts) > 0 || core::length(local.cross_binding_conflicts) > 0 || core::length(local.cross_member_conflicts) > 0
  }

  enforcement_level = input.kms-duties-enforcement-level
  enforce {
    condition     = !local.has_conflict
    error_message = "Remove either the Cloud KMS Admin role or the conflicting Cloud KMS cryptographic role from the user in this project to enforce separation of duties."
  }
}
