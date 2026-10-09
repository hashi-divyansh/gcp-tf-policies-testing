# Copyright IBM Corp. 2026

policytest {
  targets = ["8-1-dataproc-cmek.policy.hcl"]
}

resource "google_dataproc_cluster" "pass_cmek" {
  attrs = {
    name   = "pass-cmek"
    region = "us-central1"
    cluster_config = [{
      encryption_config = [{ kms_key_name = "projects/example-project/locations/us-central1/keyRings/dp-ring/cryptoKeys/dp-key" }]
    }]
  }
}

# Without encryption_config the cluster uses Google-managed keys.
resource "google_dataproc_cluster" "fail_no_encryption_config" {
  expect_failure = true
  attrs = {
    name   = "fail-no-encryption-config"
    region = "us-central1"
    cluster_config = [{
      staging_bucket = "dataproc-staging"
    }]
  }
}

resource "google_dataproc_cluster" "fail_no_cluster_config" {
  expect_failure = true
  attrs = {
    name   = "fail-no-cluster-config"
    region = "us-central1"
  }
}

resource "google_dataproc_cluster" "fail_blank_kms_key_name" {
  expect_failure = true
  attrs = {
    name   = "fail-blank-kms-key-name"
    region = "us-central1"
    cluster_config = [{
      encryption_config = [{ kms_key_name = " " }]
    }]
  }
}

# Dataproc on GKE has no Compute Engine persistent disks covered by this control.
resource "google_dataproc_cluster" "pass_virtual_cluster_out_of_scope" {
  attrs = {
    name   = "pass-virtual-cluster"
    region = "us-central1"
    virtual_cluster_config = [{
      staging_bucket = "dataproc-staging"
    }]
  }
}

resource "google_dataproc_cluster" "fail_cluster_config_without_encryption" {
  expect_failure = true
  attrs = {
    name   = "no-encryption-config"
    region = "us-central1"
    cluster_config = [{
      master_config = [{
        num_instances = 1
      }]
    }]
  }
}

# Workflow templates create managed Dataproc clusters with persistent disks.
resource "google_dataproc_workflow_template" "pass_workflow_managed_cluster_cmek" {
  attrs = {
    name     = "pass-workflow-managed-cluster-cmek"
    location = "us-central1"
    placement = [{
      managed_cluster = [{
        cluster_name = "managed"
        config = [{
          encryption_config = [{ gce_pd_kms_key_name = "projects/example-project/locations/us-central1/keyRings/dp-ring/cryptoKeys/dp-key" }]
        }]
      }]
    }]
  }
}

resource "google_dataproc_workflow_template" "fail_workflow_managed_cluster_no_encryption" {
  expect_failure = true
  attrs = {
    name     = "fail-workflow-managed-cluster-no-encryption"
    location = "us-central1"
    placement = [{
      managed_cluster = [{
        cluster_name = "managed"
        config = [{
          master_config = [{ num_instances = 1 }]
        }]
      }]
    }]
  }
}

resource "google_dataproc_workflow_template" "fail_workflow_managed_cluster_blank_key" {
  expect_failure = true
  attrs = {
    name     = "fail-workflow-managed-cluster-blank-key"
    location = "us-central1"
    placement = [{
      managed_cluster = [{
        cluster_name = "managed"
        config = [{
          encryption_config = [{ gce_pd_kms_key_name = "" }]
        }]
      }]
    }]
  }
}

# A cluster_selector runs jobs on existing clusters and creates none.
resource "google_dataproc_workflow_template" "pass_workflow_cluster_selector_out_of_scope" {
  attrs = {
    name     = "pass-workflow-cluster-selector"
    location = "us-central1"
    placement = [{
      cluster_selector = [{ cluster_labels = { env = "prod" } }]
    }]
  }
}
