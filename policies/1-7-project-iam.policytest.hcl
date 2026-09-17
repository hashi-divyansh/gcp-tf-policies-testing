# Copyright IBM Corp. 2026

policytest {
  targets = ["1-7-project-iam.policy.hcl"]
}

resource "google_project_iam_binding" "fail_service_account_user_role_for_user" {
  expect_failure = true
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountUser"
    members = ["user:alice@example.com"]
  }
}

resource "google_project_iam_binding" "fail_token_creator_role_with_user_among_members" {
  expect_failure = true
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountTokenCreator"
    members = [
      "serviceAccount:automation@example-project-id.iam.gserviceaccount.com",
      "user:bob@example.com",
    ]
  }
}

resource "google_project_iam_binding" "pass_prohibited_role_for_service_accounts_only" {
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountUser"
    members = ["serviceAccount:automation@example-project-id.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_binding" "pass_unrelated_role_for_user" {
  attrs = {
    project = "example-project-id"
    role    = "roles/viewer"
    members = ["user:carol@example.com"]
  }
}

resource "google_project_iam_member" "fail_service_account_user_role_for_user" {
  expect_failure = true
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountUser"
    member  = "user:dave@example.com"
  }
}

resource "google_project_iam_member" "fail_token_creator_role_for_user" {
  expect_failure = true
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountTokenCreator"
    member  = "user:erin@example.com"
  }
}

resource "google_project_iam_member" "pass_prohibited_role_for_service_account" {
  attrs = {
    project = "example-project-id"
    role    = "roles/iam.serviceAccountTokenCreator"
    member  = "serviceAccount:automation@example-project-id.iam.gserviceaccount.com"
  }
}

resource "google_project_iam_member" "pass_unrelated_role_for_user" {
  attrs = {
    project = "example-project-id"
    role    = "roles/viewer"
    member  = "user:frank@example.com"
  }
}
