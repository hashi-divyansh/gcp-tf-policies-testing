# Test resources for policies/30/5-1-no-public-buckets.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
# pass_bucket_fine_grained disables uniform access (required for ACLs), so it also fails 5.2.
#
# fail_bucket_iam_all_users          -> violates the policy (IAM member allUsers)
# fail_bucket_binding_all_auth_users -> violates the policy (IAM binding includes allAuthenticatedUsers)
# fail_bucket_acl_public_read        -> violates the policy (predefined_acl = publicRead)
# pass_bucket_iam_named_user         -> complies with the policy (named user only)

resource "google_storage_bucket" "pass_bucket_private" {
  name                        = "${var.project_id}-pass-bucket-private"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_storage_bucket" "pass_bucket_fine_grained" {
  name                        = "${var.project_id}-pass-bucket-fine-grained"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = false

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_storage_bucket_iam_member" "fail_bucket_iam_all_users" {
  bucket = "${var.project_id}-pass-bucket-private"
  role   = "roles/storage.objectViewer"
  member = "allUsers"

  depends_on = [time_sleep.prerequisites_ready, google_storage_bucket.pass_bucket_private]
}

resource "google_storage_bucket_iam_binding" "fail_bucket_binding_all_auth_users" {
  bucket  = "${var.project_id}-pass-bucket-private"
  role    = "roles/storage.legacyBucketReader"
  members = ["user:${var.iam_test_user_email}", "allAuthenticatedUsers"]

  depends_on = [time_sleep.prerequisites_ready, google_storage_bucket.pass_bucket_private]
}

resource "google_storage_bucket_acl" "fail_bucket_acl_public_read" {
  bucket         = "${var.project_id}-pass-bucket-fine-grained"
  predefined_acl = "publicRead"

  depends_on = [time_sleep.prerequisites_ready, google_storage_bucket.pass_bucket_fine_grained]
}

resource "google_storage_bucket_iam_member" "pass_bucket_iam_named_user" {
  bucket = "${var.project_id}-pass-bucket-private"
  role   = "roles/storage.objectViewer"
  member = "user:${var.iam_test_user_email}"

  depends_on = [time_sleep.prerequisites_ready, google_storage_bucket.pass_bucket_private]
}
