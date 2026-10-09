# Ensure API Keys Only Exist for Active Services

| Provider | Category |
| -------- | -------- |
| Google Cloud Platform | Identity and access management |

## Description

This control reports every `google_apikeys_key` resource in the plan. API key usage and age are not visible in a Terraform plan, so the policy treats the creation or modification of any API key as non-compliant. A plan that contains no `google_apikeys_key` resources complies.

API keys are long-lived bearer secrets that identify a project rather than a principal. Anyone who obtains a key can call the APIs it is allowed to use, and keys are easy to leak through source code, logs, or client applications. Google recommends using service accounts, workload identity, or OAuth credentials instead. Keys created outside Terraform, and keys that Firebase app resources in the `google-beta` provider create implicitly, are outside the scope of this policy.

This rule is covered by the [1-13-no-api-keys](https://github.com/hashicorp/prewritten-terraform-policy-library/blob/main/policies/gcp/iam/1-13-no-api-keys.policy.hcl) policy.

## Policy Results

```bash
trace:
   # 1-13-no-api-keys.policytest.hcl... 
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
   # 1-13-no-api-keys.policytest.hcl... 
   pass
```

---
