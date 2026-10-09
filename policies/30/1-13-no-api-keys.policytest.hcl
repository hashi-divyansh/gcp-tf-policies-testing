# Copyright IBM Corp. 2026

policytest {
  targets = ["1-13-no-api-keys.policy.hcl"]
}

resource "google_apikeys_key" "fail_unrestricted_key" {
  expect_failure = true
  attrs = {
    name         = "unrestricted-key"
    display_name = "Unrestricted key"
  }
}

# Restrictions do not prove the key serves an active service, so it is still reported.
resource "google_apikeys_key" "fail_restricted_key" {
  expect_failure = true
  attrs = {
    name         = "restricted-key"
    display_name = "Restricted key"
    restrictions = [{
      api_targets = [{ service = "translate.googleapis.com" }]
    }]
  }
}

# Boundary: a key with only the required name is still reported.
resource "google_apikeys_key" "fail_minimal_key" {
  expect_failure = true
  attrs = {
    name = "minimal-key"
  }
}
