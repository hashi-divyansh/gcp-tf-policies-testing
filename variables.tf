# Identities used by the CIS 1.x IAM test fixtures.
#
# GCP rejects an IAM binding whose `user:` principal does not exist, so these
# fixtures cannot be applied with a placeholder address. Set these as HCP
# Terraform workspace variables rather than committing a real address here.
#
# The 1-7 / 1-9 / 1-12 policies only evaluate members carrying the `user:`
# prefix, so a service account cannot be substituted -- doing so would make
# every `fail_*` fixture pass vacuously.

variable "iam_test_user_email" {
  description = "Real Google account email (no `user:` prefix) used by the IAM test fixtures."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.iam_test_user_email))
    error_message = "iam_test_user_email must be a bare email address, without the `user:` prefix."
  }
}

variable "iam_test_user_email_alt" {
  description = <<-EOT
    A second, distinct real Google account email used only by the separation-of-duties
    `pass_*` fixtures in 1-9 and 1-12. Those cases assert that a principal holding just
    one of two conflicting roles is compliant, which cannot be expressed with the same
    principal that the `fail_*` fixtures already grant both roles to. Leave empty to
    skip those two resources; the `.policytest.hcl` mocks still cover the pass paths.
  EOT
  type        = string
  default     = ""
}
