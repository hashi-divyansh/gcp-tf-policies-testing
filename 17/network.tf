# Shared network resources reused across the compute-instance and
# subnetwork policy test files below, to avoid creating a new VPC per file.

resource "google_compute_subnetwork" "shared_subnet" {
  name          = "policy-test-shared-subnet"
  network       = google_compute_network.test_3_6_vpc.name
  ip_cidr_range = "10.10.0.0/24"
  region        = "us-central1"
}
