# Test resources for policies/1-12-kms-duties.policy.hcl
#
# ⚠️ SAFETY: google_project_iam_member grants a REAL IAM role on your GCP
# project if applied. Recommended: run `terraform plan` only. If you do
# `apply`, run `terraform destroy` on these resources immediately after.
#
# The member identity comes from var.iam_test_user_email. GCP rejects a
# binding whose `user:` principal does not exist, so this must be a real
# Google account before `apply` will succeed. This policy only evaluates
# members with the `user:` prefix, so a service account cannot be used.
#
# fail_kms_admin_and_crypto_conflict -> violates the policy (the same user
#   holds both roles/cloudkms.admin and a crypto key role)
# pass_kms_admin_only                -> complies with the policy (only one
#   of the two conflicting roles)

resource "google_project_iam_member" "fail_kms_admin_and_crypto_conflict" {
  depends_on = [google_project_iam_member.pass_sa_admin_only]

  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.admin"
  member  = "user:${var.iam_test_user_email}"
}

resource "google_project_iam_member" "fail_kms_admin_and_crypto_conflict_2" {
  depends_on = [google_project_iam_member.fail_kms_admin_and_crypto_conflict]

  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "user:${var.iam_test_user_email}"
}

# Needs a principal distinct from var.iam_test_user_email: that identity is
# already granted both conflicting roles above, so reusing it here would
# duplicate fail_kms_admin_and_crypto_conflict instead of exercising the pass
# path. Skipped when var.iam_test_user_email_alt is empty.
resource "google_project_iam_member" "pass_kms_admin_only" {
  count = var.iam_test_user_email_alt != "" ? 1 : 0

  depends_on = [google_project_iam_member.fail_kms_admin_and_crypto_conflict_2]

  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.admin"
  member  = "user:${var.iam_test_user_email_alt}"
}
