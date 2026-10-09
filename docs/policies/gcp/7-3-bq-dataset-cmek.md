# Ensure That a Default Customer-Managed Encryption Key (CMEK) Is Specified for All BigQuery Data Sets

| Provider | Category |
| -------- | -------- |
| Google Cloud Platform | Encryption of data-at-rest |

## Description

This control checks that `google_bigquery_dataset` resources set a non-empty `default_encryption_configuration.kms_key_name`.

A dataset default customer-managed key makes every new table in the dataset use CMEK unless a table specifies its own key. This prevents tables from being created with Google-managed encryption by mistake.

This rule is covered by the [7-3-bq-dataset-cmek](https://github.com/hashicorp/prewritten-terraform-policy-library/blob/main/policies/gcp/bigquery/7-3-bq-dataset-cmek.policy.hcl) policy.

## Policy Results

```bash
trace:
   # 7-3-bq-dataset-cmek.policytest.hcl... 
   running
   # resource.google_bigquery_dataset.pass_default_cmek... 
   running
   # resource.google_bigquery_dataset.pass_default_cmek... 
   pass
   # resource.google_bigquery_dataset.fail_no_default_encryption... 
   running
   # resource.google_bigquery_dataset.fail_no_default_encryption... 
   pass
   # resource.google_bigquery_dataset.fail_empty_kms_key_name... 
   running
   # resource.google_bigquery_dataset.fail_empty_kms_key_name... 
   pass
   # resource.google_bigquery_dataset.fail_blank_kms_key_name... 
   running
   # resource.google_bigquery_dataset.fail_blank_kms_key_name... 
   pass
   # 7-3-bq-dataset-cmek.policytest.hcl... 
   pass
```

---
