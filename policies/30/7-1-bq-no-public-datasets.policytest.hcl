# Copyright IBM Corp. 2026

policytest {
  targets = ["7-1-bq-no-public-datasets.policy.hcl"]
}

resource "google_bigquery_dataset" "pass_private_access" {
  attrs = {
    dataset_id = "pass_private_access"
    location   = "US"
    access = [
      { role = "OWNER", special_group = "projectOwners" },
      { role = "READER", user_by_email = "analyst@example.com" },
    ]
  }
}

resource "google_bigquery_dataset" "pass_no_access_blocks" {
  attrs = {
    dataset_id = "pass_no_access_blocks"
    location   = "US"
  }
}

resource "google_bigquery_dataset" "fail_all_authenticated_users_special_group" {
  expect_failure = true
  attrs = {
    dataset_id = "fail_all_authenticated_users_special_group"
    location   = "US"
    access = [
      { role = "OWNER", special_group = "projectOwners" },
      { role = "READER", special_group = "allAuthenticatedUsers" },
    ]
  }
}

resource "google_bigquery_dataset" "fail_all_users_iam_member" {
  expect_failure = true
  attrs = {
    dataset_id = "fail_all_users_iam_member"
    location   = "US"
    access = [
      { role = "READER", iam_member = "allUsers" },
    ]
  }
}

resource "google_bigquery_dataset_access" "pass_access_resource_private" {
  attrs = {
    dataset_id    = "ds"
    role          = "READER"
    user_by_email = "analyst@example.com"
  }
}

resource "google_bigquery_dataset_access" "fail_access_resource_all_authenticated_users" {
  expect_failure = true
  attrs = {
    dataset_id    = "ds"
    role          = "READER"
    special_group = "allAuthenticatedUsers"
  }
}

resource "google_bigquery_dataset_access" "fail_access_resource_all_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "READER"
    iam_member = "allUsers"
  }
}

resource "google_bigquery_dataset_iam_member" "pass_iam_member_user" {
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    member     = "user:analyst@example.com"
  }
}

resource "google_bigquery_dataset_iam_member" "fail_iam_member_all_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    member     = "allUsers"
  }
}

resource "google_bigquery_dataset_iam_binding" "pass_iam_binding_users" {
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    members    = ["user:analyst@example.com", "group:data@example.com"]
  }
}

resource "google_bigquery_dataset_iam_binding" "fail_iam_binding_all_authenticated_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    members    = ["user:analyst@example.com", "allAuthenticatedUsers"]
  }
}

resource "google_bigquery_dataset_iam_policy" "pass_iam_policy_private" {
  attrs = {
    dataset_id  = "ds"
    policy_data = "{\"bindings\":[{\"role\":\"roles/bigquery.dataViewer\",\"members\":[\"user:analyst@example.com\"]}]}"
  }
}

# Only exact public principals are matched, not substrings of other members.
resource "google_bigquery_dataset_iam_policy" "pass_iam_policy_user_named_like_public" {
  attrs = {
    dataset_id  = "ds"
    policy_data = "{\"bindings\":[{\"role\":\"roles/bigquery.dataViewer\",\"members\":[\"user:allusers-reporting@example.com\"]}]}"
  }
}

resource "google_bigquery_dataset_iam_policy" "fail_iam_policy_all_users" {
  expect_failure = true
  attrs = {
    dataset_id  = "ds"
    policy_data = "{\"bindings\":[{\"role\":\"roles/bigquery.dataViewer\",\"members\":[\"user:analyst@example.com\",\"allUsers\"]}]}"
  }
}

# special_group also matches allUsers, not only allAuthenticatedUsers.
resource "google_bigquery_dataset" "fail_all_users_special_group" {
  expect_failure = true
  attrs = {
    dataset_id = "fail_all_users_special_group"
    location   = "US"
    access = [
      { role = "READER", special_group = "allUsers" },
    ]
  }
}

resource "google_bigquery_dataset" "fail_all_authenticated_users_iam_member" {
  expect_failure = true
  attrs = {
    dataset_id = "fail_all_authenticated_users_iam_member"
    location   = "US"
    access = [
      { role = "READER", iam_member = "allAuthenticatedUsers" },
    ]
  }
}

# A domain grant is limited to that domain's users, so it is not public.
resource "google_bigquery_dataset" "pass_domain_access" {
  attrs = {
    dataset_id = "pass_domain_access"
    location   = "US"
    access = [
      { role = "READER", domain = "example.com" },
    ]
  }
}

resource "google_bigquery_dataset_access" "fail_access_resource_special_group_all_users" {
  expect_failure = true
  attrs = {
    dataset_id    = "ds"
    role          = "READER"
    special_group = "allUsers"
  }
}

# The dataset IAM resources only accept allUsers as "iamMember:allUsers".
resource "google_bigquery_dataset_iam_member" "fail_iam_member_prefixed_all_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    member     = "iamMember:allUsers"
  }
}

resource "google_bigquery_dataset_iam_member" "fail_iam_member_all_authenticated_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    member     = "allAuthenticatedUsers"
  }
}

resource "google_bigquery_dataset_iam_binding" "fail_iam_binding_prefixed_all_users" {
  expect_failure = true
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    members    = ["iamMember:allUsers"]
  }
}

resource "google_bigquery_dataset_iam_binding" "pass_iam_binding_empty_members" {
  attrs = {
    dataset_id = "ds"
    role       = "roles/bigquery.dataViewer"
    members    = []
  }
}

resource "google_bigquery_dataset_iam_policy" "fail_iam_policy_prefixed_all_authenticated_users" {
  expect_failure = true
  attrs = {
    dataset_id  = "ds"
    policy_data = "{\"bindings\":[{\"role\":\"roles/bigquery.dataViewer\",\"members\":[\"iamMember:allAuthenticatedUsers\"]}]}"
  }
}

resource "google_bigquery_dataset_iam_policy" "pass_iam_policy_no_bindings" {
  attrs = {
    dataset_id  = "ds"
    policy_data = "{}"
  }
}
