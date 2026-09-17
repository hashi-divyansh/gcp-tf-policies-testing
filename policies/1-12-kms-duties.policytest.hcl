# Copyright IBM Corp. 2026

policytest {
  targets = ["1-12-kms-duties.policy.hcl"]
}

resource "google_project_iam_binding" "pass_admin_without_crypto_role" {
  attrs = {
    project = "pass-admin-project"
    role    = "roles/cloudkms.admin"
    members = ["user:admin-only@example.com"]
  }
}

resource "google_project_iam_member" "pass_crypto_without_admin_role" {
  attrs = {
    project = "pass-crypto-project"
    role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member  = "user:crypto-only@example.com"
  }
}

resource "google_project_iam_binding" "fail_admin_with_encrypter_decrypter" {
  expect_failure = true
  attrs = {
    project = "fail-encrypter-decrypter-project"
    role    = "roles/cloudkms.admin"
    members = ["user:conflict-ed@example.com"]
  }
}

resource "google_project_iam_member" "fail_encrypter_decrypter_with_admin" {
  expect_failure = true
  attrs = {
    project = "fail-encrypter-decrypter-project"
    role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member  = "user:conflict-ed@example.com"
  }
}

resource "google_project_iam_member" "fail_admin_with_encrypter" {
  expect_failure = true
  attrs = {
    project = "fail-encrypter-project"
    role    = "roles/cloudkms.admin"
    member  = "user:conflict-e@example.com"
  }
}

resource "google_project_iam_binding" "fail_encrypter_with_admin" {
  expect_failure = true
  attrs = {
    project = "fail-encrypter-project"
    role    = "roles/cloudkms.cryptoKeyEncrypter"
    members = ["user:conflict-e@example.com"]
  }
}

resource "google_project_iam_member" "fail_admin_with_decrypter" {
  expect_failure = true
  attrs = {
    project = "fail-decrypter-project"
    role    = "roles/cloudkms.admin"
    member  = "user:conflict-d@example.com"
  }
}

resource "google_project_iam_binding" "fail_decrypter_with_admin" {
  expect_failure = true
  attrs = {
    project = "fail-decrypter-project"
    role    = "roles/cloudkms.cryptoKeyDecrypter"
    members = ["user:conflict-d@example.com"]
  }
}

resource "google_project_iam_binding" "pass_non_user_admin" {
  attrs = {
    project = "service-account-project"
    role    = "roles/cloudkms.admin"
    members = ["serviceAccount:kms@example.iam.gserviceaccount.com"]
  }
}

resource "google_project_iam_member" "pass_non_user_crypto" {
  attrs = {
    project = "service-account-project"
    role    = "roles/cloudkms.cryptoKeyEncrypter"
    member  = "serviceAccount:kms@example.iam.gserviceaccount.com"
  }
}

resource "google_project_iam_binding" "pass_admin_in_different_project" {
  attrs = {
    project = "separate-admin-project"
    role    = "roles/cloudkms.admin"
    members = ["user:cross-project@example.com"]
  }
}

resource "google_project_iam_member" "pass_crypto_in_different_project" {
  attrs = {
    project = "separate-crypto-project"
    role    = "roles/cloudkms.cryptoKeyDecrypter"
    member  = "user:cross-project@example.com"
  }
}

resource "google_project_iam_binding" "pass_empty_members" {
  attrs = {
    project = "empty-members-project"
    role    = "roles/cloudkms.admin"
    members = []
  }
}

resource "google_project_iam_binding" "pass_null_members" {
  attrs = {
    project = "null-members-project"
    role    = "roles/cloudkms.admin"
    members = null
  }
}

resource "google_project_iam_member" "pass_null_member" {
  attrs = {
    project = "null-member-project"
    role    = "roles/cloudkms.admin"
    member  = null
  }
}
