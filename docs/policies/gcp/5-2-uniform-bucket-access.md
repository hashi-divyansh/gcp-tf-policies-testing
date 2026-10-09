# Ensure That Cloud Storage Buckets Have Uniform Bucket-Level Access Enabled

| Provider | Category |
| -------- | -------- |
| Google Cloud Platform | Storage security |

## Description

This control checks that `google_storage_bucket` resources set `uniform_bucket_level_access` to `true`. The provider default is `false`, so a bucket that omits the argument is non-compliant.

Uniform bucket-level access disables object ACLs and makes IAM the only mechanism that grants access to a bucket and its objects. This removes the risk of individual objects becoming public through ACLs and makes access easier to audit. Because the argument is optional and computed, a bucket that omits it may be reported as unknown during a real plan rather than as failed; set it explicitly to get a definite result.

This rule is covered by the [5-2-uniform-bucket-access](https://github.com/hashicorp/prewritten-terraform-policy-library/blob/main/policies/gcp/storage/5-2-uniform-bucket-access.policy.hcl) policy.

## Policy Results

```bash
trace:
   # 5-2-uniform-bucket-access.policytest.hcl... 
   running
   # resource.google_storage_bucket.pass_ubla_enabled... 
   running
   # resource.google_storage_bucket.pass_ubla_enabled... 
   pass
   # resource.google_storage_bucket.fail_ubla_disabled... 
   running
   # resource.google_storage_bucket.fail_ubla_disabled... 
   pass
   # resource.google_storage_bucket.fail_ubla_unset... 
   running
   # resource.google_storage_bucket.fail_ubla_unset... 
   pass
   # resource.google_storage_bucket.fail_ubla_disabled_with_pap_enforced... 
   running
   # resource.google_storage_bucket.fail_ubla_disabled_with_pap_enforced... 
   pass
   # 5-2-uniform-bucket-access.policytest.hcl... 
   pass
```

---
