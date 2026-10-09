# Test resources for policies/30/5-2-uniform-bucket-access.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_bucket_ubla_disabled -> violates the policy (uniform_bucket_level_access = false)
# pass_bucket_ubla_enabled  -> complies with the policy (uniform_bucket_level_access = true)
#
# uniform_bucket_level_access is set explicitly because it is computed (unknown at plan) when omitted.

resource "google_storage_bucket" "fail_bucket_ubla_disabled" {
  name                        = "${var.project_id}-fail-bucket-ubla-disabled"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = false

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_storage_bucket" "pass_bucket_ubla_enabled" {
  name                        = "${var.project_id}-pass-bucket-ubla-enabled"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [time_sleep.prerequisites_ready]
}
