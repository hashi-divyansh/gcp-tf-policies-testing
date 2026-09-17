# Copyright IBM Corp. 2026

# Ensure that VPC Flow Logs is Enabled for Every Subnet in a VPC Network

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

resource_policy "google_compute_subnetwork" "cis_gcp_3_10_vpc_flow_logs" {
  operations = ["create", "update"]

  filter = !core::contains(
    ["REGIONAL_MANAGED_PROXY", "GLOBAL_MANAGED_PROXY"],
    core::try(attrs.purpose, null),
  )

  locals {
    log_config_raw = core::try(attrs.log_config[0], attrs.log_config, null)
    has_log_config = local.log_config_raw != null

    aggregation_interval_raw = core::try(local.log_config_raw.aggregation_interval, null)
    aggregation_interval     = local.aggregation_interval_raw != null ? local.aggregation_interval_raw : ""

    flow_sampling_raw = core::try(local.log_config_raw.flow_sampling, null)
    flow_sampling     = local.flow_sampling_raw != null ? local.flow_sampling_raw : 0

    metadata_raw = core::try(local.log_config_raw.metadata, null)
    metadata     = local.metadata_raw != null ? local.metadata_raw : ""

    flow_logs_compliant = local.has_log_config && local.aggregation_interval == "INTERVAL_5_SEC" && local.flow_sampling == 1 && local.metadata == "INCLUDE_ALL_METADATA"
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.flow_logs_compliant
    error_message = "Enable VPC Flow Logs and set aggregation_interval to INTERVAL_5_SEC, flow_sampling to 1, and metadata to INCLUDE_ALL_METADATA."
  }
}
