# Copyright IBM Corp. 2026

# Ensure That BigQuery Datasets Are Not Anonymously or Publicly Accessible

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "bq-no-public-datasets-enforcement-level" {
  type    = string
  default = "advisory"
}

# Dataset-level access only; table IAM is out of scope.

locals {
  bq_public_principals = ["allUsers", "allAuthenticatedUsers"]
  # Dataset IAM resources also accept the iamMember: prefix.
  bq_public_iam_members = ["allUsers", "allAuthenticatedUsers", "iamMember:allUsers", "iamMember:allAuthenticatedUsers"]
}

resource_policy "google_bigquery_dataset" "dataset_access_not_public" {
  locals {
    # Test the length: try() is unknown for partially-unknown values. An omitted access block is unknown at plan.
    access = core::try(core::length(attrs.access), 0) > 0 ? [for entry in attrs.access : entry] : []
    public_access = [
      for entry in local.access : entry
      if core::contains(local.bq_public_principals, core::try(entry.special_group, null) != null ? entry.special_group : "") || core::contains(local.bq_public_principals, core::try(entry.iam_member, null) != null ? entry.iam_member : "")
    ]
  }

  enforcement_level = input.bq-no-public-datasets-enforcement-level
  enforce {
    condition     = core::length(local.public_access) == 0
    error_message = "BigQuery datasets must not grant access to allUsers or allAuthenticatedUsers. Remove those principals from the dataset access blocks."
  }
}

resource_policy "google_bigquery_dataset_access" "dataset_access_not_public" {
  locals {
    special_group_raw = core::try(attrs.special_group, null)
    iam_member_raw    = core::try(attrs.iam_member, null)
    is_public         = core::contains(local.bq_public_principals, local.special_group_raw != null ? local.special_group_raw : "") || core::contains(local.bq_public_principals, local.iam_member_raw != null ? local.iam_member_raw : "")
  }

  enforcement_level = input.bq-no-public-datasets-enforcement-level
  enforce {
    condition     = !local.is_public
    error_message = "google_bigquery_dataset_access must not grant access to allUsers or allAuthenticatedUsers. Grant access to specific users, groups, or domains instead."
  }
}

resource_policy "google_bigquery_dataset_iam_member" "dataset_iam_member_not_public" {
  locals {
    member_raw = core::try(attrs.member, null)
    member     = local.member_raw != null ? local.member_raw : ""
  }

  enforcement_level = input.bq-no-public-datasets-enforcement-level
  enforce {
    condition     = !core::contains(local.bq_public_iam_members, local.member)
    error_message = "BigQuery dataset IAM members must not be allUsers or allAuthenticatedUsers. Grant the role to specific users, groups, or service accounts instead."
  }
}

resource_policy "google_bigquery_dataset_iam_binding" "dataset_iam_binding_not_public" {
  locals {
    members_raw    = core::try(attrs.members, null)
    members        = local.members_raw != null ? [for member in local.members_raw : member] : []
    public_members = [for member in local.members : member if core::contains(local.bq_public_iam_members, member)]
  }

  enforcement_level = input.bq-no-public-datasets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "BigQuery dataset IAM bindings must not include allUsers or allAuthenticatedUsers. Remove those members from the binding."
  }
}

resource_policy "google_bigquery_dataset_iam_policy" "dataset_iam_policy_not_public" {
  locals {
    policy_data_raw = core::try(attrs.policy_data, null)
    policy_doc      = core::try(core::jsondecode(local.policy_data_raw != null ? local.policy_data_raw : ""), {})
    bindings_raw    = core::try(local.policy_doc.bindings, null)
    bindings        = local.bindings_raw != null ? local.bindings_raw : []
    public_members = core::flatten([
      for binding in local.bindings : [
        for member in(core::try(binding.members, null) != null ? binding.members : []) : member
        if core::contains(local.bq_public_iam_members, member)
      ]
    ])
  }

  enforcement_level = input.bq-no-public-datasets-enforcement-level
  enforce {
    condition     = core::length(local.public_members) == 0
    error_message = "BigQuery dataset IAM policies must not bind any role to allUsers or allAuthenticatedUsers. Remove those members from policy_data."
  }
}
