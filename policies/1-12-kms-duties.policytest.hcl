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

# google_project_iam_policy is authoritative: it replaces the entire
# project IAM policy, so its bindings must be checked directly rather
# than through google_project_iam_binding/member.
# The Admin role and a conflicting crypto role can appear in a single
# policy_data document.
resource "google_project_iam_policy" "pass_project_iam_policy_no_conflict" {
  attrs = {
    project     = "pass-policy-project"
    policy_data = "{\"bindings\":[{\"role\":\"roles/cloudkms.admin\",\"members\":[\"user:admin-only@example.com\"]},{\"role\":\"roles/cloudkms.cryptoKeyDecrypter\",\"members\":[\"user:crypto-only@example.com\"]}]}"
  }
}

resource "google_project_iam_policy" "fail_project_iam_policy_same_user_conflict" {
  expect_failure = true
  attrs = {
    project     = "fail-policy-project"
    policy_data = "{\"bindings\":[{\"role\":\"roles/cloudkms.admin\",\"members\":[\"user:conflict@example.com\"]},{\"role\":\"roles/cloudkms.cryptoKeyEncrypterDecrypter\",\"members\":[\"user:conflict@example.com\"]}]}"
  }
}

resource "google_project_iam_policy" "pass_project_iam_policy_data_omitted" {
  attrs = {
    project = "pass-policy-omitted-project"
  }
}

# FAIL: Admin comes from a google_project_iam_policy and the conflicting
# crypto role comes from a separate google_project_iam_member in the same
# project.
resource "google_project_iam_policy" "fail_cross_resource_policy_admin" {
  expect_failure = true
  attrs = {
    project     = "fail-cross-policy-member-project"
    policy_data = "{\"bindings\":[{\"role\":\"roles/cloudkms.admin\",\"members\":[\"user:ivan@example.com\"]}]}"
  }
}

resource "google_project_iam_member" "fail_cross_resource_member_crypto" {
  expect_failure = true
  attrs = {
    project = "fail-cross-policy-member-project"
    role    = "roles/cloudkms.cryptoKeyEncrypter"
    member  = "user:ivan@example.com"
  }
}
