# Ensure That the Cloud SQL Database Instance Requires All Incoming Connections To Use SSL

| Provider | Category |
| -------- | -------- |
| Google Cloud Platform | Encryption of data-in-transit |

## Description

This control checks that `google_sql_database_instance` resources set `settings.ip_configuration.ssl_mode` to `ENCRYPTED_ONLY` or `TRUSTED_CLIENT_CERTIFICATE_REQUIRED`. An omitted `ssl_mode` is treated as `ALLOW_UNENCRYPTED_AND_ENCRYPTED`, which is non-compliant. The deprecated `require_ssl` argument is not used because it is not available in provider v7.

Without enforced SSL/TLS, clients can connect over unencrypted channels, which exposes credentials and query results to interception and tampering. Requiring encrypted connections protects data in transit between applications and the database.

This rule is covered by the [6-4-sql-require-ssl](https://github.com/hashicorp/prewritten-terraform-policy-library/blob/main/policies/gcp/sql/6-4-sql-require-ssl.policy.hcl) policy.

## Policy Results

```bash
trace:
   # 6-4-sql-require-ssl.policytest.hcl... 
   running
   # resource.google_sql_database_instance.pass_encrypted_only... 
   running
   # resource.google_sql_database_instance.pass_encrypted_only... 
   pass
   # resource.google_sql_database_instance.pass_trusted_client_certificate_required... 
   running
   # resource.google_sql_database_instance.pass_trusted_client_certificate_required... 
   pass
   # resource.google_sql_database_instance.fail_allow_unencrypted... 
   running
   # resource.google_sql_database_instance.fail_allow_unencrypted... 
   pass
   # resource.google_sql_database_instance.fail_ssl_mode_unset... 
   running
   # resource.google_sql_database_instance.fail_ssl_mode_unset... 
   pass
   # resource.google_sql_database_instance.fail_no_ip_configuration... 
   running
   # resource.google_sql_database_instance.fail_no_ip_configuration... 
   pass
   # 6-4-sql-require-ssl.policytest.hcl... 
   pass
```

---
