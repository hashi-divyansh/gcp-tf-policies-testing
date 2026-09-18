# Test resources for policies/1-9-sa-separation.policy.hcl
#
# ⚠️ SAFETY: google_project_iam_member grants a REAL IAM role on your GCP
# project if applied. Recommended: run `terraform plan` only. If you do
# `apply`, run `terraform destroy` on these resources immediately after.
#
# Replace REPLACE_WITH_YOUR_EMAIL below with your own Google account email
# if you want to actually `apply` this (a `terraform plan` works fine with
# the placeholder left as-is).
#
# fail_sa_admin_and_user_conflict -> violates the policy (the same user holds
#   both roles/iam.serviceAccountAdmin and roles/iam.serviceAccountUser)
# pass_sa_admin_only              -> complies with the policy (only one of
#   the two conflicting roles)

resource "google_project_iam_member" "fail_sa_admin_and_user_conflict" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/iam.serviceAccountAdmin"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}

resource "google_project_iam_member" "fail_sa_admin_and_user_conflict_2" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/iam.serviceAccountUser"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}

resource "google_project_iam_member" "pass_sa_admin_only" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/iam.serviceAccountAdmin"
  member  = "user:another-user@example.com"
}
