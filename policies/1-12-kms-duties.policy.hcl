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

locals {
  kms_admin_role = "roles/cloudkms.admin"
  kms_crypto_roles = [
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudkms.cryptoKeyDecrypter",
  ]
  all_project_iam_bindings = core::getresources("google_project_iam_binding", {})
  all_project_iam_members  = core::getresources("google_project_iam_member", {})
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
    has_conflict = core::length(local.conflicts_in_bindings) > 0 || core::length(local.conflicts_in_members) > 0
  }

  enforcement_level = "advisory"
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
    has_conflict = core::length(local.conflicts_in_bindings) > 0 || core::length(local.conflicts_in_members) > 0
  }

  enforcement_level = "advisory"
  enforce {
    condition     = !local.is_user || !(local.is_admin || local.is_crypto) || !local.has_conflict
    error_message = "Remove either the Cloud KMS Admin role or the conflicting Cloud KMS cryptographic role from the user in this project to enforce separation of duties."
  }
}
