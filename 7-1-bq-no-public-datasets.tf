# Test resources for policies/30/7-1-bq-no-public-datasets.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_bq_dataset_access_all_users      -> violates the policy (access block iam_member = allUsers)
# fail_bq_dataset_member_all_auth_users -> violates the policy (IAM member allAuthenticatedUsers)
# pass_bq_dataset_private               -> complies with the policy (only a named user)

resource "google_bigquery_dataset" "fail_bq_dataset_access_all_users" {
  dataset_id                 = "fail_bq_dataset_access_all_users"
  project                    = var.project_id
  location                   = "US"
  delete_contents_on_destroy = true
  default_encryption_configuration {
    kms_key_name = "projects/${var.project_id}/locations/us/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
  }
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role       = "READER"
    iam_member = "allUsers"
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_bigquery_dataset" "pass_bq_dataset_private" {
  dataset_id                 = "pass_bq_dataset_private"
  project                    = var.project_id
  location                   = "US"
  delete_contents_on_destroy = true
  default_encryption_configuration {
    kms_key_name = "projects/${var.project_id}/locations/us/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
  }
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    user_by_email = var.iam_test_user_email
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_bigquery_dataset_iam_member" "fail_bq_dataset_member_all_auth_users" {
  project    = var.project_id
  dataset_id = "pass_bq_dataset_private"
  role       = "roles/bigquery.dataViewer"
  member     = "allAuthenticatedUsers"

  depends_on = [time_sleep.prerequisites_ready, google_bigquery_dataset.pass_bq_dataset_private]
}
