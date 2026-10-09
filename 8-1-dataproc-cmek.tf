# Test resources for policies/30/8-1-dataproc-cmek.policy.hcl
#
# Shared infrastructure (KMS keys, policy-test-vpc, subnet) comes from prerequisites.tf.
#
# fail_dataproc_google_managed -> violates the policy (no encryption_config)
# pass_dataproc_cmek           -> complies with the policy (encryption_config.kms_key_name set)

resource "google_dataproc_cluster" "fail_dataproc_google_managed" {
  name   = "fail-dataproc-google-managed"
  region = "us-central1"

  cluster_config {
    gce_cluster_config {
      subnetwork             = "projects/${var.project_id}/regions/us-central1/subnetworks/policy-test-subnet"
      internal_ip_only       = true
      service_account        = "policy-test-dataproc@${var.project_id}.iam.gserviceaccount.com"
      service_account_scopes = ["cloud-platform"]
    }

    master_config {
      num_instances = 1
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}

resource "google_dataproc_cluster" "pass_dataproc_cmek" {
  name   = "pass-dataproc-cmek"
  region = "us-central1"

  cluster_config {
    encryption_config {
      kms_key_name = "projects/${var.project_id}/locations/us-central1/keyRings/policy-test-ring/cryptoKeys/policy-test-key"
    }

    gce_cluster_config {
      subnetwork             = "projects/${var.project_id}/regions/us-central1/subnetworks/policy-test-subnet"
      internal_ip_only       = true
      service_account        = "policy-test-dataproc@${var.project_id}.iam.gserviceaccount.com"
      service_account_scopes = ["cloud-platform"]
    }

    master_config {
      num_instances = 1
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }
  }

  depends_on = [time_sleep.prerequisites_ready]
}
