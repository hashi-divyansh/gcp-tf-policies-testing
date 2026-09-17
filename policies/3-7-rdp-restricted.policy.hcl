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

    # TCP and "all protocols" rules both expose RDP.
    protocol_allow_rules = [for rule in local.allow_rules : rule if core::contains(["tcp", "all"], core::lower(core::try(rule.protocol, "")))]
    rdp_allow_rules = [for rule in local.protocol_allow_rules : rule if
      core::length(core::try(rule.ports, null) != null ? rule.ports : []) == 0 ||
      core::length([for port in (core::try(rule.ports, null) != null ? rule.ports : []) : port if
        port == "3389" ||
        (core::length(core::split("-", port)) == 2 &&
          core::try(core::parseint(core::split("-", port)[0], 10), 3389) <= 3389 &&
          core::try(core::parseint(core::split("-", port)[1], 10), 3389) >= 3389)
      ]) > 0
    ]

    exposes_rdp = local.direction == "INGRESS" && !local.disabled && core::contains(local.source_ranges, "0.0.0.0/0") && core::length(local.rdp_allow_rules) > 0
  }

  enforcement_level = "advisory"
  enforce {
    condition     = !local.exposes_rdp
    error_message = "RDP access on TCP port 3389 must not be allowed from 0.0.0.0/0. Replace the unrestricted source with specific trusted IPv4 addresses or CIDR ranges."
  }
}
