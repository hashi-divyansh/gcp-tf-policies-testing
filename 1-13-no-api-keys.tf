# Test resources for policies/30/1-13-no-api-keys.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_api_key_restricted -> reported by the policy: every API key is flagged, because CIS 1.13
#                            requires that no API keys exist and key usage cannot be checked in a plan.
#
# There is no pass case; a project without google_apikeys_key resources complies.

resource "google_apikeys_key" "fail_api_key_restricted" {
  name         = "fail-api-key-restricted"
  display_name = "Policy test key"
  project      = var.project_id

  restrictions {
    api_targets {
      service = "translate.googleapis.com"
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}
