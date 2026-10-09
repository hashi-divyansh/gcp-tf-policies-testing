# Copyright IBM Corp. 2026

# Ensure that Dataproc Cluster is encrypted using Customer-Managed Encryption Key

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "dataproc-cmek-enforcement-level" {
  type    = string
  default = "advisory"
}

# Serverless batches, session templates and Metastore are out of scope.

resource_policy "google_dataproc_cluster" "cluster_encrypted_with_cmek" {
  locals {
    # Dataproc on GKE has no Compute Engine disks and is excluded. Test the length: try() is
    # unknown for partially-unknown blocks. An omitted cluster_config is unknown at plan.
    has_cluster_config = core::try(core::length(attrs.cluster_config), 0) > 0
    is_virtual_cluster = local.has_cluster_config ? false : core::try(core::length(attrs.virtual_cluster_config), 0) > 0

    kms_key_raw = core::try(attrs.cluster_config[0].encryption_config[0].kms_key_name, null)
    kms_key     = local.kms_key_raw != null ? core::trimspace(local.kms_key_raw) : ""
  }

  filter = !local.is_virtual_cluster

  enforcement_level = input.dataproc-cmek-enforcement-level
  enforce {
    condition     = local.kms_key != ""
    error_message = "Dataproc clusters must set cluster_config.encryption_config.kms_key_name to a customer-managed Cloud KMS key. Google-managed encryption is non-compliant."
  }
}

resource_policy "google_dataproc_workflow_template" "workflow_managed_cluster_encrypted_with_cmek" {
  locals {
    # Only managed clusters are created here; cluster_selector reuses existing clusters.
    has_managed_cluster = core::try(core::length(attrs.placement[0].managed_cluster), 0) > 0

    kms_key_raw = core::try(attrs.placement[0].managed_cluster[0].config[0].encryption_config[0].gce_pd_kms_key_name, null)
    kms_key     = local.kms_key_raw != null ? core::trimspace(local.kms_key_raw) : ""
  }

  filter = local.has_managed_cluster

  enforcement_level = input.dataproc-cmek-enforcement-level
  enforce {
    condition     = local.kms_key != ""
    error_message = "Dataproc workflow templates with a managed cluster must set placement.managed_cluster.config.encryption_config.gce_pd_kms_key_name to a customer-managed Cloud KMS key. Google-managed encryption is non-compliant."
  }
}
