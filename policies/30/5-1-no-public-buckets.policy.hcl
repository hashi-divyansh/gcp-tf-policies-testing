# Copyright IBM Corp. 2026

# Ensure That Cloud Storage Bucket Is Not Anonymously or Publicly Accessible

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "no-public-buckets-enforcement-level" {
  type    = string
  default = "advisory"
}

# Public principals are matched exactly. IAM conditions and public access prevention
# are not treated as mitigating.
locals {
  storage_public_principals = ["allUsers", "allAuthenticatedUsers"]
  # Predefined bucket ACLs that grant access to allUsers or allAuthenticatedUsers.
  storage_public_predefined_acls = ["publicread", "publicreadwrite", "authenticatedread"]
}

resource_policy "google_storage_bucket_iam_member" "bucket_iam_member_not_public" {
  locals {
    member_raw = core::try(attrs.member, null)
    member     = local.member_raw != null ? local.member_raw : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = !core::contains(local.storage_public_principals, local.member)
    error_message = "Cloud Storage bucket IAM members must not be allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_bucket_iam_binding" "bucket_iam_binding_not_public" {
  locals {
    members_raw    = core::try(attrs.members, null)
    members        = local.members_raw != null ? [for member in local.members_raw : member] : []
    public_members = [for member in local.members : member if core::contains(local.storage_public_principals, member)]
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "Cloud Storage bucket IAM bindings must not include allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_bucket_iam_policy" "bucket_iam_policy_not_public" {
  locals {
    policy_data_raw = core::try(attrs.policy_data, null)
    policy_doc      = core::try(core::jsondecode(local.policy_data_raw != null ? local.policy_data_raw : ""), {})
    bindings_raw    = core::try(local.policy_doc.bindings, null)
    bindings        = local.bindings_raw != null ? local.bindings_raw : []
    public_members = core::flatten([
      for binding in local.bindings : [
        for member in(core::try(binding.members, null) != null ? binding.members : []) : member
        if core::contains(local.storage_public_principals, member)
      ]
    ])
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "Cloud Storage bucket IAM policies must not bind any role to allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_bucket_access_control" "bucket_access_control_not_public" {
  locals {
    entity_raw = core::try(attrs.entity, null)
    entity     = local.entity_raw != null ? local.entity_raw : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = !core::contains(local.storage_public_principals, local.entity)
    error_message = "Cloud Storage bucket ACL entries must not grant access to allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_bucket_acl" "bucket_acl_not_public" {
  locals {
    role_entities_raw = core::try(attrs.role_entity, null)
    role_entities     = local.role_entities_raw != null ? [for entry in local.role_entities_raw : entry] : []
    # role_entity entries use the "ROLE:entity" format, e.g. "READER:allUsers".
    public_entries = [
      for entry in local.role_entities : entry
      if core::contains(local.storage_public_principals, core::try(core::split(":", entry)[1], ""))
    ]
    predefined_acl_raw = core::try(attrs.predefined_acl, null)
    predefined_acl     = local.predefined_acl_raw != null ? core::lower(local.predefined_acl_raw) : ""
    # default_acl is the predefined default object ACL applied to new objects.
    default_acl_raw = core::try(attrs.default_acl, null)
    default_acl     = local.default_acl_raw != null ? core::lower(local.default_acl_raw) : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    # role_entity is unknown at plan when predefined_acl is used.
    condition     = local.predefined_acl != "" ? !core::contains(local.storage_public_predefined_acls, local.predefined_acl) : core::length(local.public_entries) == 0
    error_message = "Cloud Storage bucket ACLs must not grant access to allUsers or allAuthenticatedUsers, including via the publicRead, publicReadWrite, or authenticatedRead predefined ACLs."
  }

  enforce {
    condition     = !core::contains(local.storage_public_predefined_acls, local.default_acl)
    error_message = "Cloud Storage bucket ACLs must not set default_acl to publicRead, publicReadWrite, or authenticatedRead, which makes new objects public."
  }
}

# Beyond the CIS audit: object ACLs and managed folder IAM.
resource_policy "google_storage_default_object_acl" "default_object_acl_not_public" {
  locals {
    role_entities_raw = core::try(attrs.role_entity, null)
    role_entities     = local.role_entities_raw != null ? [for entry in local.role_entities_raw : entry] : []
    public_entries = [
      for entry in local.role_entities : entry
      if core::contains(local.storage_public_principals, core::try(core::split(":", entry)[1], ""))
    ]
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = core::length(local.public_entries) == 0
    error_message = "Cloud Storage default object ACLs must not grant access to allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_default_object_access_control" "default_object_access_control_not_public" {
  locals {
    entity_raw = core::try(attrs.entity, null)
    entity     = local.entity_raw != null ? local.entity_raw : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = !core::contains(local.storage_public_principals, local.entity)
    error_message = "Cloud Storage default object ACL entries must not grant access to allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_object_acl" "object_acl_not_public" {
  locals {
    role_entities_raw = core::try(attrs.role_entity, null)
    role_entities     = local.role_entities_raw != null ? [for entry in local.role_entities_raw : entry] : []
    public_entries = [
      for entry in local.role_entities : entry
      if core::contains(local.storage_public_principals, core::try(core::split(":", entry)[1], ""))
    ]
    predefined_acl_raw = core::try(attrs.predefined_acl, null)
    predefined_acl     = local.predefined_acl_raw != null ? core::lower(local.predefined_acl_raw) : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    # role_entity is computed (unknown at plan) when predefined_acl is used.
    condition     = local.predefined_acl != "" ? !core::contains(local.storage_public_predefined_acls, local.predefined_acl) : core::length(local.public_entries) == 0
    error_message = "Cloud Storage object ACLs must not grant access to allUsers or allAuthenticatedUsers, including via the publicRead or authenticatedRead predefined ACLs."
  }
}

resource_policy "google_storage_object_access_control" "object_access_control_not_public" {
  locals {
    entity_raw = core::try(attrs.entity, null)
    entity     = local.entity_raw != null ? local.entity_raw : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = !core::contains(local.storage_public_principals, local.entity)
    error_message = "Cloud Storage object ACL entries must not grant access to allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_managed_folder_iam_member" "managed_folder_iam_member_not_public" {
  locals {
    member_raw = core::try(attrs.member, null)
    member     = local.member_raw != null ? local.member_raw : ""
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = !core::contains(local.storage_public_principals, local.member)
    error_message = "Cloud Storage managed folder IAM members must not be allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_managed_folder_iam_binding" "managed_folder_iam_binding_not_public" {
  locals {
    members_raw    = core::try(attrs.members, null)
    members        = local.members_raw != null ? [for member in local.members_raw : member] : []
    public_members = [for member in local.members : member if core::contains(local.storage_public_principals, member)]
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "Cloud Storage managed folder IAM bindings must not include allUsers or allAuthenticatedUsers."
  }
}

resource_policy "google_storage_managed_folder_iam_policy" "managed_folder_iam_policy_not_public" {
  locals {
    policy_data_raw = core::try(attrs.policy_data, null)
    policy_doc      = core::try(core::jsondecode(local.policy_data_raw != null ? local.policy_data_raw : ""), {})
    bindings_raw    = core::try(local.policy_doc.bindings, null)
    bindings        = local.bindings_raw != null ? local.bindings_raw : []
    public_members = core::flatten([
      for binding in local.bindings : [
        for member in(core::try(binding.members, null) != null ? binding.members : []) : member
        if core::contains(local.storage_public_principals, member)
      ]
    ])
  }

  enforcement_level = input.no-public-buckets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "Cloud Storage managed folder IAM policies must not bind any role to allUsers or allAuthenticatedUsers."
  }
}
