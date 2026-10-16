# Ensure API Keys Only Exist for Active Services

| Provider | Category | CIS Control (GCP v5.0.0) |
| -------- | -------- | ------------------------ |
| Google Cloud Platform | Identity and access management | 1.13 |

## Description

This control reports every `google_apikeys_key` resource in the plan. API key usage and age are not visible in a Terraform plan, so the policy treats the creation or modification of any API key as non-compliant. A plan that contains no `google_apikeys_key` resources complies.

The policy rejects every `google_apikeys_key` resource, including keys restricted to specific APIs, applications, or IP addresses. There are no exceptions and no allow-list. Restricted keys therefore still fail this policy, even when they satisfy other API-key controls in the benchmark. If your organization needs API keys, keep this policy at `advisory` and use the API-key restriction controls.

This follows the CIS GCP Foundations Benchmark v5.0.0 control 1.13 audit, which requires no API keys to be listed. It is stricter than [Google's general API-key guidance](https://cloud.google.com/docs/authentication/api-keys-best-practices), which permits necessary, restricted keys and recommends deleting unused keys.

API keys are long-lived bearer secrets that identify a project rather than a principal. Anyone who obtains a key can call the APIs it is allowed to use, and keys are easy to leak through source code, logs, or client applications. Google recommends using service accounts, workload identity, or OAuth credentials instead. Keys created outside Terraform, and keys that Firebase app resources in the `google-beta` provider create implicitly, are outside the scope of this policy.

This rule is covered by the [api-keys-active-services-only](https://github.com/hashicorp/prewritten-terraform-policy-library/blob/main/policies/gcp/iam/api-keys-active-services-only.policy.hcl) policy.

## Policy Results

```bash
trace:
   # api-keys-active-services-only.policytest.hcl...
   running
   # resource.google_apikeys_key.fail_unrestricted_key...
   running
   # resource.google_apikeys_key.fail_unrestricted_key...
   pass
   # resource.google_apikeys_key.fail_restricted_key...
   running
   # resource.google_apikeys_key.fail_restricted_key...
   pass
   # resource.google_apikeys_key.fail_minimal_key...
   running
   # resource.google_apikeys_key.fail_minimal_key...
   pass
   # api-keys-active-services-only.policytest.hcl...
   pass
```

---
