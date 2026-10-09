# Test resources for policies/1-7-project-iam.policy.hcl
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
# fail_sa_admin_and_user_conflict_2 in 1-9-sa-separation.tf also exercises
# this policy's failure path. Defining the same project, role, and member
# twice would make two Terraform resources manage one GCP IAM membership.
# pass_user_has_viewer_role complies with the policy (unrelated role).

resource "google_project_iam_member" "pass_user_has_viewer_role" {
  depends_on = [google_project_iam_member.pass_sa_has_viewer_role]

  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/viewer"
  member  = "user:${var.iam_test_user_email}"
}
