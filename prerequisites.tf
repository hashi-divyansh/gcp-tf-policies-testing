# Shared infrastructure that the test resources need for a real apply.
#
# The test resources reference these by literal name (not by Terraform reference)
# so that every attribute the policies read stays known at plan time. Ordering is
# enforced with depends_on = [time_sleep.prerequisites_ready] instead.
#
# Notes for apply/destroy:
# - Cloud KMS key rings and keys cannot be deleted. Destroy only schedules the key
#   versions for destruction and removes them from state. To apply again after a
#   destroy, import the existing key rings and keys first.
# - None of these resource types are evaluated by the policies in policies/30.

locals {
  required_services = [
    "apikeys.googleapis.com",
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "dataproc.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ]

  compute_service_agent  = "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com"
  dataproc_service_agent = "serviceAccount:service-${var.project_number}@dataproc-accounts.iam.gserviceaccount.com"
}

variable "project_number" {
  description = "Project number of var.project_id (used to build service agent emails without a plan-time API call)."
  type        = string
  default     = "417057796316"
}

variable "iam_test_user_email" {
  description = "Existing Google account used as the named, non-public member in the bucket and dataset test resources."
  type        = string
  default     = "divyansh-singh@hashicorp.com"

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.iam_test_user_email))
    error_message = "iam_test_user_email must be a bare email address, without the `user:` prefix."
  }
}

# ---------------------------------------------------------------------------
# APIs
# ---------------------------------------------------------------------------

resource "google_project_service" "required" {
  for_each = toset(local.required_services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Service agents are created asynchronously after their API is enabled.
resource "time_sleep" "apis_ready" {
  create_duration = "60s"
  depends_on      = [google_project_service.required]
}

# ---------------------------------------------------------------------------
# Network: policy-test-vpc with private services access for Cloud SQL
# ---------------------------------------------------------------------------

resource "google_compute_network" "policy_test" {
  project                 = var.project_id
  name                    = "policy-test-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.required]
}

resource "google_compute_subnetwork" "policy_test" {
  project                  = var.project_id
  name                     = "policy-test-subnet"
  region                   = "us-central1"
  network                  = google_compute_network.policy_test.id
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}

# Dataproc nodes must reach each other on all ports.
resource "google_compute_firewall" "policy_test_internal" {
  project       = var.project_id
  name          = "policy-test-allow-internal"
  network       = google_compute_network.policy_test.id
  source_ranges = [google_compute_subnetwork.policy_test.ip_cidr_range]

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_global_address" "private_services" {
  project       = var.project_id
  name          = "policy-test-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.policy_test.id
}

resource "google_service_networking_connection" "private_services" {
  network                 = google_compute_network.policy_test.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]
}

# ---------------------------------------------------------------------------
# Cloud KMS: policy-test-ring/policy-test-key in "us" (BigQuery) and
# "us-central1" (Compute Engine disks and Dataproc)
# ---------------------------------------------------------------------------

resource "google_kms_key_ring" "us" {
  project    = var.project_id
  name       = "policy-test-ring"
  location   = "us"
  depends_on = [google_project_service.required]
}

resource "google_kms_crypto_key" "us" {
  name     = "policy-test-key"
  key_ring = google_kms_key_ring.us.id
}

resource "google_kms_key_ring" "us_central1" {
  project    = var.project_id
  name       = "policy-test-ring"
  location   = "us-central1"
  depends_on = [google_project_service.required]
}

resource "google_kms_crypto_key" "us_central1" {
  name     = "policy-test-key"
  key_ring = google_kms_key_ring.us_central1.id
}

data "google_bigquery_default_service_account" "this" {
  project    = var.project_id
  depends_on = [time_sleep.apis_ready]
}

resource "google_kms_crypto_key_iam_member" "bigquery" {
  crypto_key_id = google_kms_crypto_key.us.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = data.google_bigquery_default_service_account.this.member
}

resource "google_kms_crypto_key_iam_member" "us_central1" {
  for_each = {
    compute  = local.compute_service_agent
    dataproc = local.dataproc_service_agent
  }

  crypto_key_id = google_kms_crypto_key.us_central1.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = each.value
  depends_on    = [time_sleep.apis_ready]
}

# ---------------------------------------------------------------------------
# Dataproc VM service account and SQL Server root password
# ---------------------------------------------------------------------------

resource "google_service_account" "dataproc" {
  project      = var.project_id
  account_id   = "policy-test-dataproc"
  display_name = "Dataproc policy test VMs"
  depends_on   = [google_project_service.required]
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = google_service_account.dataproc.member
}

# Cloud SQL for SQL Server requires a root password at creation.
resource "random_password" "sqlserver_root" {
  length  = 24
  special = true
}

# ---------------------------------------------------------------------------
# Single dependency anchor for the test resources. The wait lets IAM grants
# propagate before resources that use the KMS keys are created.
# ---------------------------------------------------------------------------

resource "time_sleep" "prerequisites_ready" {
  create_duration = "60s"

  depends_on = [
    google_compute_firewall.policy_test_internal,
    google_compute_subnetwork.policy_test,
    google_kms_crypto_key_iam_member.bigquery,
    google_kms_crypto_key_iam_member.us_central1,
    google_project_iam_member.dataproc_worker,
    google_service_networking_connection.private_services,
  ]
}
