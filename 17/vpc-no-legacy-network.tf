# Test resources for policies/vpc-no-legacy-network.policy.hcl
#
# No dedicated resource is needed here: the shared VPC
# (google_compute_network.test_3_6_vpc, defined in vpc-firewall-ssh-internet-access-restricted.tf)
# already exercises this policy on every plan/apply.
#
# gateway_ipv4 is a computed, output-only attribute -- current Terraform
# provider versions have no argument that can create a legacy network, so
# this policy can only ever report:
#   - "Unknown" while the network is still being created (gateway_ipv4 is
#     "(known after apply)"), or
#   - "Passed" once applied, since a modern (non-legacy) network resolves
#     gateway_ipv4 to an empty string.
#
# See policies/vpc-no-legacy-network.policy.hcl for the full rationale.
