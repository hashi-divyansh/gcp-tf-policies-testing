# Test resources for policies/1-12-kms-duties.policy.hcl
#
# ⚠️ SAFETY: google_project_iam_member grants a REAL IAM role on your GCP
# project if applied. Recommended: run `terraform plan` only. If you do
# `apply`, run `terraform destroy` on these resources immediately after.
#
# Replace REPLACE_WITH_YOUR_EMAIL below with your own Google account email
# if you want to actually `apply` this (a `terraform plan` works fine with
# the placeholder left as-is).
#
# fail_kms_admin_and_crypto_conflict -> violates the policy (the same user
#   holds both roles/cloudkms.admin and a crypto key role)
# pass_kms_admin_only                -> complies with the policy (only one
#   of the two conflicting roles)

resource "google_project_iam_member" "fail_kms_admin_and_crypto_conflict" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.admin"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}

resource "google_project_iam_member" "fail_kms_admin_and_crypto_conflict_2" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}

resource "google_project_iam_member" "pass_kms_admin_only" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.admin"
  member  = "user:another-user@example.com"
}
