# Copyright IBM Corp. 2026

# Ensure That RDP Access Is Restricted From the Internet

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "rdp-restricted-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_firewall" "restrict_rdp_from_internet" {
  operations = ["create", "update"]

  locals {
    direction_raw    = core::try(attrs.direction, null)
    direction        = local.direction_raw != null && local.direction_raw != "" ? core::upper(local.direction_raw) : "INGRESS"
    disabled_raw     = core::try(attrs.disabled, null)
    disabled         = local.disabled_raw == null ? false : local.disabled_raw
    source_ranges_raw = core::try(attrs.source_ranges, null)
    source_ranges     = local.source_ranges_raw != null ? local.source_ranges_raw : []
    allow_rules_raw   = core::try(attrs.allow, null)
    allow_rules       = local.allow_rules_raw != null ? local.allow_rules_raw : []

    # TCP (by name "tcp" or IP protocol number "6") and "all protocols"
    # rules both expose RDP.
    protocol_allow_rules = [for rule in local.allow_rules : rule if core::contains(["tcp", "6", "all"], core::lower(core::try(rule.protocol, "")))]
    rdp_allow_rules = [for rule in local.protocol_allow_rules : rule if
      core::length(core::try(rule.ports, null) != null ? rule.ports : []) == 0 ||
      core::length([for port in (core::try(rule.ports, null) != null ? rule.ports : []) : port if
        port == "3389" ||
        (core::length(core::split("-", port)) == 2 &&
          core::try(core::parseint(core::split("-", port)[0], 10), 3389) <= 3389 &&
          core::try(core::parseint(core::split("-", port)[1], 10), 3389) >= 3389)
      ]) > 0
    ]

    # A /0 prefix covers the entire address space whatever address precedes
    # it, so matching on prefix length catches every spelling of "open to
    # the internet" in both families: 0.0.0.0/0, ::/0, 0::/0, ::0/0.
    # Known gap: split ranges (0.0.0.0/1 + 128.0.0.0/1) are not detected.
    unrestricted = core::length([for r in local.source_ranges : r if core::endswith(core::trimspace(r), "/0")]) > 0

    exposes_rdp = local.direction == "INGRESS" && !local.disabled && local.unrestricted && core::length(local.rdp_allow_rules) > 0
  }

  enforcement_level = input.rdp-restricted-enforcement-level
  enforce {
    condition     = !local.exposes_rdp
    error_message = "RDP access on TCP port 3389 must not be allowed from an unrestricted source range such as 0.0.0.0/0 or ::/0. Replace it with specific trusted addresses or CIDR ranges."
  }
}
