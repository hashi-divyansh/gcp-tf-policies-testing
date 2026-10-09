# Test resources for policies/1-6-sa-no-admin.policy.hcl
#
# ⚠️ SAFETY: google_project_iam_member grants a REAL IAM role on your GCP
# project if applied. Recommended: run `terraform plan` only to see the
# policy evaluation results. If you do `apply`, run `terraform destroy`
# on these two resources immediately after to revert the grant.
#
# fail_sa_has_admin_role -> violates the policy (service account granted
#                           an Admin-named role)
# pass_sa_has_viewer_role -> complies with the policy (least-privilege role)

resource "google_project_iam_member" "fail_sa_has_admin_role" {
  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/cloudkms.admin"
  member  = "serviceAccount:hcp-terraform-runner@hc-f31985686df247b5bbd6a432306.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "pass_sa_has_viewer_role" {
  depends_on = [google_project_iam_member.fail_sa_has_admin_role]

  project = "hc-f31985686df247b5bbd6a432306"
  role    = "roles/viewer"
  member  = "serviceAccount:hcp-terraform-runner@hc-f31985686df247b5bbd6a432306.iam.gserviceaccount.com"
}
