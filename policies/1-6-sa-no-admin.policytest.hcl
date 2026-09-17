# Copyright IBM Corp. 2026

policytest {
  targets = ["1-6-sa-no-admin.policy.hcl"]
}

resource "google_project_iam_binding" "pass_service_account_viewer" {
  attrs = {
    project = "test-project"
    role    = "roles/viewer"
    members = ["serviceAccount:app@test-project.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_binding" "fail_service_account_owner" {
  expect_failure = true
  attrs = {
    project = "test-project"
    role    = "roles/owner"
    members = ["serviceAccount:app@test-project.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_binding" "fail_service_account_admin_role" {
  expect_failure = true
  attrs = {
    project = "test-project"
    role    = "roles/iam.serviceAccountAdmin"
    members = ["serviceAccount:app@test-project.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_binding" "pass_user_owner" {
  attrs = {
    project = "test-project"
    role    = "roles/owner"
    members = ["user:administrator@example.com"]
  }
}

resource "google_project_iam_binding" "pass_empty_members" {
  attrs = {
    project = "test-project"
    role    = "roles/owner"
    members = []
  }
}

resource "google_project_iam_member" "pass_service_account_viewer" {
  attrs = {
    project = "test-project"
    role    = "roles/viewer"
    member  = "serviceAccount:app@test-project.iam.gserviceaccount.com"
  }
}

resource "google_project_iam_member" "fail_service_account_editor" {
  expect_failure = true
  attrs = {
    project = "test-project"
    role    = "roles/editor"
    member  = "serviceAccount:app@test-project.iam.gserviceaccount.com"
  }
}

resource "google_project_iam_member" "fail_service_account_admin_role" {
  expect_failure = true
  attrs = {
    project = "test-project"
    role    = "projects/test-project/roles/networkadmin"
    member  = "serviceAccount:app@test-project.iam.gserviceaccount.com"
  }
}

resource "google_project_iam_member" "pass_group_editor" {
  attrs = {
    project = "test-project"
    role    = "roles/editor"
    member  = "group:administrators@example.com"
  }
}

resource "google_project_iam_member" "pass_null_member" {
  attrs = {
    project = "test-project"
    role    = "roles/owner"
    member  = null
  }
}
