# Test resources for policies/1-7-project-iam.policy.hcl
#
# ⚠️ SAFETY: google_project_iam_member grants a REAL IAM role on your GCP
# project if applied. Recommended: run `terraform plan` only. If you do
# `apply`, run `terraform destroy` on these resources immediately after.
#
# Replace REPLACE_WITH_YOUR_EMAIL below with your own Google account email
# if you want to actually `apply` this (a `terraform plan` works fine with
# the placeholder left as-is, since plan does not call the GCP API to
# validate that the member identity exists).
#
# fail_user_has_sa_user_role -> violates the policy (user granted
#                               roles/iam.serviceAccountUser at project level)
# pass_user_has_viewer_role  -> complies with the policy (unrelated role)

resource "google_project_iam_member" "fail_user_has_sa_user_role" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/iam.serviceAccountUser"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}

resource "google_project_iam_member" "pass_user_has_viewer_role" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/viewer"
  member  = "user:REPLACE_WITH_YOUR_EMAIL@example.com"
}
