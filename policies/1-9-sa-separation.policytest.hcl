# Copyright IBM Corp. 2026

policytest {
  targets = ["1-9-sa-separation.policy.hcl"]
}

# PASS: Each role may be assigned individually to different users in one project.
resource "google_project_iam_binding" "pass_admin_for_alice" {
  attrs = {
    project = "pass-different-users"
    role    = "roles/iam.serviceAccountAdmin"
    members = ["user:alice@example.com"]
  }
}

resource "google_project_iam_binding" "pass_user_for_bob" {
  attrs = {
    project = "pass-different-users"
    role    = "roles/iam.serviceAccountUser"
    members = ["user:bob@example.com"]
  }
}

# PASS: Grants in different projects must not be combined.
resource "google_project_iam_member" "pass_admin_in_first_project" {
  attrs = {
    project = "pass-project-one"
    role    = "roles/iam.serviceAccountAdmin"
    member  = "user:carol@example.com"
  }
}

resource "google_project_iam_member" "pass_user_in_second_project" {
  attrs = {
    project = "pass-project-two"
    role    = "roles/iam.serviceAccountUser"
    member  = "user:carol@example.com"
  }
}

# PASS: The control applies only to user identities.
resource "google_project_iam_binding" "pass_non_user_admin" {
  attrs = {
    project = "pass-non-user"
    role    = "roles/iam.serviceAccountAdmin"
    members = ["serviceAccount:automation@example-project.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_binding" "pass_non_user_user" {
  attrs = {
    project = "pass-non-user"
    role    = "roles/iam.serviceAccountUser"
    members = ["serviceAccount:automation@example-project.iam.gserviceaccount.com"]
  }
}

# FAIL: The same user receives both roles through bindings.
resource "google_project_iam_binding" "fail_binding_admin" {
  expect_failure = true
  attrs = {
    project = "fail-bindings"
    role    = "roles/iam.serviceAccountAdmin"
    members = ["user:dana@example.com"]
  }
}

resource "google_project_iam_binding" "fail_binding_user" {
  expect_failure = true
  attrs = {
    project = "fail-bindings"
    role    = "roles/iam.serviceAccountUser"
    members = ["user:dana@example.com"]
  }
}

# FAIL: The same user receives both roles through individual member grants.
resource "google_project_iam_member" "fail_member_admin" {
  expect_failure = true
  attrs = {
    project = "fail-members"
    role    = "roles/iam.serviceAccountAdmin"
    member  = "user:erin@example.com"
  }
}

resource "google_project_iam_member" "fail_member_user" {
  expect_failure = true
  attrs = {
    project = "fail-members"
    role    = "roles/iam.serviceAccountUser"
    member  = "user:erin@example.com"
  }
}

# FAIL: Admin comes from a binding and User comes from an individual grant.
resource "google_project_iam_binding" "fail_cross_type_binding_admin" {
  expect_failure = true
  attrs = {
    project = "fail-cross-admin-binding"
    role    = "roles/iam.serviceAccountAdmin"
    members = ["user:frank@example.com", "user:safe@example.com"]
  }
}

resource "google_project_iam_member" "fail_cross_type_member_user" {
  expect_failure = true
  attrs = {
    project = "fail-cross-admin-binding"
    role    = "roles/iam.serviceAccountUser"
    member  = "user:frank@example.com"
  }
}

# FAIL: Admin comes from an individual grant and User comes from a binding.
resource "google_project_iam_member" "fail_cross_type_member_admin" {
  expect_failure = true
  attrs = {
    project = "fail-cross-user-binding"
    role    = "roles/iam.serviceAccountAdmin"
    member  = "user:grace@example.com"
  }
}

resource "google_project_iam_binding" "fail_cross_type_binding_user" {
  expect_failure = true
  attrs = {
    project = "fail-cross-user-binding"
    role    = "roles/iam.serviceAccountUser"
    members = ["user:grace@example.com"]
  }
}
