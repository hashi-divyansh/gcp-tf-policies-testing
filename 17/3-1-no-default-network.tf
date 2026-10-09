# Test resources for policies/3-1-no-default-network.policy.hcl
#
# The shared VPC (google_compute_network.test_3_6_vpc, defined in
# 3-6-restrict-ssh.tf) already exercises the PASS case, since its name is
# not "default".
#
# fail_default_network below demonstrates the violation case, but is left
# commented out: every GCP project already has a network literally named
# "default", so creating another resource with that same name will fail at
# apply time with a name-collision error from the GCP API. Uncomment only to
# inspect the "Advisory" result during `terraform plan` -- do not `apply` it.

# resource "google_compute_network" "fail_default_network" {
#   name                    = "default"
#   auto_create_subnetworks = false
# }
