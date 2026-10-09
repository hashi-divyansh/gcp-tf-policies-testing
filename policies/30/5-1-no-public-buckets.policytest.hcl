# Copyright IBM Corp. 2026

policytest {
  targets = ["5-1-no-public-buckets.policy.hcl"]
}

resource "google_storage_bucket_iam_member" "pass_iam_member_user" {
  attrs = {
    bucket = "example-bucket"
    role   = "roles/storage.objectViewer"
    member = "user:analyst@example.com"
  }
}

resource "google_storage_bucket_iam_member" "fail_iam_member_all_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "roles/storage.objectViewer"
    member = "allUsers"
  }
}

resource "google_storage_bucket_iam_member" "fail_iam_member_all_authenticated_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "roles/storage.objectViewer"
    member = "allAuthenticatedUsers"
  }
}

resource "google_storage_bucket_iam_binding" "pass_iam_binding_private" {
  attrs = {
    bucket  = "example-bucket"
    role    = "roles/storage.objectViewer"
    members = ["user:analyst@example.com", "group:data@example.com"]
  }
}

resource "google_storage_bucket_iam_binding" "fail_iam_binding_all_users" {
  expect_failure = true
  attrs = {
    bucket  = "example-bucket"
    role    = "roles/storage.objectViewer"
    members = ["user:analyst@example.com", "allUsers"]
  }
}

resource "google_storage_bucket_iam_policy" "pass_iam_policy_private" {
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\",\"members\":[\"user:analyst@example.com\"]}]}"
  }
}

# Only exact public principals are matched, not substrings of other members.
resource "google_storage_bucket_iam_policy" "pass_iam_policy_user_named_like_public" {
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\",\"members\":[\"user:allusers-reporting@example.com\"]}]}"
  }
}

resource "google_storage_bucket_iam_policy" "fail_iam_policy_all_authenticated_users" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\",\"members\":[\"user:analyst@example.com\",\"allAuthenticatedUsers\"]}]}"
  }
}

resource "google_storage_bucket_access_control" "pass_access_control_user" {
  attrs = {
    bucket = "example-bucket"
    role   = "READER"
    entity = "user-analyst@example.com"
  }
}

resource "google_storage_bucket_access_control" "fail_access_control_all_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "READER"
    entity = "allUsers"
  }
}

resource "google_storage_bucket_acl" "pass_acl_private" {
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["OWNER:project-owners-123456", "READER:user-analyst@example.com"]
  }
}

resource "google_storage_bucket_acl" "pass_acl_private_predefined" {
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "projectPrivate"
  }
}

resource "google_storage_bucket_acl" "fail_acl_all_users_entity" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["OWNER:project-owners-123456", "READER:allUsers"]
  }
}

resource "google_storage_bucket_acl" "fail_acl_all_authenticated_users_entity" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["READER:allAuthenticatedUsers"]
  }
}

resource "google_storage_bucket_acl" "fail_acl_public_read_predefined" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "publicRead"
  }
}

resource "google_storage_bucket_acl" "fail_acl_authenticated_read_predefined" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "authenticatedRead"
  }
}

resource "google_storage_bucket_acl" "fail_acl_public_read_write_predefined_mixed_case" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "PublicReadWrite"
  }
}

resource "google_storage_bucket_acl" "fail_acl_public_default_object_acl" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "projectPrivate"
    default_acl    = "publicRead"
  }
}

resource "google_storage_bucket_acl" "pass_acl_private_default_object_acl" {
  attrs = {
    bucket         = "example-bucket"
    predefined_acl = "projectPrivate"
    default_acl    = "bucketOwnerRead"
  }
}

resource "google_storage_default_object_acl" "pass_default_object_acl_private" {
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["OWNER:project-owners-123456", "READER:user-analyst@example.com"]
  }
}

resource "google_storage_default_object_acl" "fail_default_object_acl_all_users" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["OWNER:project-owners-123456", "READER:allUsers"]
  }
}

resource "google_storage_default_object_access_control" "pass_default_object_access_control_user" {
  attrs = {
    bucket = "example-bucket"
    role   = "READER"
    entity = "user-analyst@example.com"
  }
}

resource "google_storage_default_object_access_control" "fail_default_object_access_control_all_auth_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "READER"
    entity = "allAuthenticatedUsers"
  }
}

resource "google_storage_object_acl" "pass_object_acl_private_predefined" {
  attrs = {
    bucket         = "example-bucket"
    object         = "report.csv"
    predefined_acl = "bucketOwnerRead"
  }
}

resource "google_storage_object_acl" "fail_object_acl_public_read_predefined" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    object         = "report.csv"
    predefined_acl = "publicRead"
  }
}

resource "google_storage_object_acl" "fail_object_acl_all_users_entity" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    object      = "report.csv"
    role_entity = ["READER:allUsers"]
  }
}

resource "google_storage_object_access_control" "pass_object_access_control_user" {
  attrs = {
    bucket = "example-bucket"
    object = "report.csv"
    role   = "READER"
    entity = "user-analyst@example.com"
  }
}

resource "google_storage_object_access_control" "fail_object_access_control_all_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    object = "report.csv"
    role   = "READER"
    entity = "allUsers"
  }
}

resource "google_storage_managed_folder_iam_member" "pass_managed_folder_member_user" {
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    role           = "roles/storage.objectViewer"
    member         = "user:analyst@example.com"
  }
}

resource "google_storage_managed_folder_iam_member" "fail_managed_folder_member_all_users" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    role           = "roles/storage.objectViewer"
    member         = "allUsers"
  }
}

resource "google_storage_managed_folder_iam_binding" "fail_managed_folder_binding_all_auth_users" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    role           = "roles/storage.objectViewer"
    members        = ["user:analyst@example.com", "allAuthenticatedUsers"]
  }
}

resource "google_storage_managed_folder_iam_policy" "pass_managed_folder_policy_private" {
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    policy_data    = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\",\"members\":[\"user:analyst@example.com\"]}]}"
  }
}

resource "google_storage_managed_folder_iam_policy" "fail_managed_folder_policy_all_users" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    policy_data    = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\",\"members\":[\"allUsers\"]}]}"
  }
}

# Regression: exact principal matching for IAM members and ACL entities.
resource "google_storage_bucket_iam_member" "pass_iam_member_user_named_like_public" {
  attrs = {
    bucket = "example-bucket"
    role   = "roles/storage.objectViewer"
    member = "group:allusers@example.com"
  }
}

resource "google_storage_bucket_acl" "pass_acl_group_named_like_public" {
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["READER:group-allauthenticatedusers@example.com"]
  }
}

# IAM Conditions cannot be applied to allUsers or allAuthenticatedUsers, so a
# condition does not exempt a public binding.
resource "google_storage_bucket_iam_member" "fail_iam_member_all_users_with_condition" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "roles/storage.objectViewer"
    member = "allUsers"
    condition = [{
      title      = "expires"
      expression = "request.time < timestamp(\"2030-01-01T00:00:00Z\")"
    }]
  }
}

resource "google_storage_bucket_iam_binding" "fail_iam_binding_all_auth_users_with_condition" {
  expect_failure = true
  attrs = {
    bucket  = "example-bucket"
    role    = "roles/storage.objectViewer"
    members = ["allAuthenticatedUsers"]
    condition = [{
      title      = "expires"
      expression = "request.time < timestamp(\"2030-01-01T00:00:00Z\")"
    }]
  }
}

# Boundary: IAM policy documents without bindings or members are private.
resource "google_storage_bucket_iam_policy" "pass_iam_policy_no_bindings" {
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{}"
  }
}

resource "google_storage_bucket_iam_policy" "pass_iam_policy_binding_without_members" {
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{\"bindings\":[{\"role\":\"roles/storage.objectViewer\"}]}"
  }
}

# A public member in a later binding is still detected.
resource "google_storage_bucket_iam_policy" "fail_iam_policy_all_users_second_binding" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    policy_data = "{\"bindings\":[{\"role\":\"roles/storage.admin\",\"members\":[\"group:admins@example.com\"]},{\"role\":\"roles/storage.legacyBucketReader\",\"members\":[\"allUsers\"]}]}"
  }
}

resource "google_storage_bucket_access_control" "fail_access_control_all_authenticated_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    role   = "READER"
    entity = "allAuthenticatedUsers"
  }
}

resource "google_storage_bucket_acl" "fail_acl_authenticated_read_default_object_acl" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["OWNER:project-owners-123456"]
    default_acl = "authenticatedRead"
  }
}

resource "google_storage_default_object_acl" "pass_default_object_acl_empty" {
  attrs = {
    bucket      = "example-bucket"
    role_entity = []
  }
}

resource "google_storage_default_object_acl" "fail_default_object_acl_all_authenticated_users" {
  expect_failure = true
  attrs = {
    bucket      = "example-bucket"
    role_entity = ["READER:allAuthenticatedUsers"]
  }
}

resource "google_storage_object_acl" "pass_object_acl_private_entities" {
  attrs = {
    bucket      = "example-bucket"
    object      = "report.csv"
    role_entity = ["OWNER:project-owners-123456", "READER:user-analyst@example.com"]
  }
}

resource "google_storage_object_acl" "fail_object_acl_authenticated_read_predefined" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    object         = "report.csv"
    predefined_acl = "authenticatedRead"
  }
}

resource "google_storage_object_access_control" "fail_object_access_control_all_authenticated_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    object = "report.csv"
    role   = "READER"
    entity = "allAuthenticatedUsers"
  }
}

resource "google_storage_managed_folder_iam_member" "fail_managed_folder_member_all_auth_users" {
  expect_failure = true
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    role           = "roles/storage.objectViewer"
    member         = "allAuthenticatedUsers"
  }
}

resource "google_storage_managed_folder_iam_binding" "pass_managed_folder_binding_private" {
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    role           = "roles/storage.objectViewer"
    members        = ["user:analyst@example.com", "group:data@example.com"]
  }
}

resource "google_storage_managed_folder_iam_policy" "pass_managed_folder_policy_no_bindings" {
  attrs = {
    bucket         = "example-bucket"
    managed_folder = "reports/"
    policy_data    = "{}"
  }
}
