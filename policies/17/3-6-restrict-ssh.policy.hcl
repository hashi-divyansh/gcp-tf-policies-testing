# Copyright IBM Corp. 2026

# Ensure That SSH Access Is Restricted From the Internet

policy {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

input "restrict-ssh-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "google_compute_firewall" "restrict_ssh_from_internet" {
  operations = ["create", "update"]

  locals {
    direction_raw    = core::try(attrs.direction, null)
    direction        = local.direction_raw != null && local.direction_raw != "" ? core::upper(local.direction_raw) : "INGRESS"
    disabled_raw     = core::try(attrs.disabled, null)
    disabled         = local.disabled_raw == null ? false : local.disabled_raw
    source_ranges_raw = core::try(attrs.source_ranges, null)
    source_ranges     = local.source_ranges_raw != null ? local.source_ranges_raw : []
    allow_raw         = core::try(attrs.allow, null)
    allow             = local.allow_raw != null ? local.allow_raw : []
    allow_rules       = [for a in local.allow : {
      protocol = core::try(a.protocol, null) != null ? core::lower(a.protocol) : ""
      ports    = core::try(a.ports, null) != null ? a.ports : []
    }]
    # A /0 prefix covers the entire address space whatever address precedes
    # it, so matching on prefix length catches every spelling of "open to
    # the internet" in both families: 0.0.0.0/0, ::/0, 0::/0, ::0/0.
    # Known gap: split ranges (0.0.0.0/1 + 128.0.0.0/1) are not detected.
    unrestricted     = core::length([for r in local.source_ranges : r if core::endswith(core::trimspace(r), "/0")]) > 0
    # "tcp" or its IP protocol number "6" both match TCP traffic;
    # "all" covers every protocol.
    ssh_allow_rules   = [for a in local.allow_rules : a if core::contains(["tcp", "6", "all"], a.protocol) && (core::length(a.ports) == 0 || core::length([for p in a.ports : p if p == "22" || (core::length(core::split("-", p)) == 2 && core::try(core::parseint(core::try(core::split("-", p)[0], ""), 10), -1) <= 22 && core::try(core::parseint(core::try(core::split("-", p)[1], ""), 10), -1) >= 22)]) > 0)]
    exposes_ssh       = core::length(local.ssh_allow_rules) > 0
    compliant         = local.disabled || local.direction != "INGRESS" || !local.unrestricted || !local.exposes_ssh
  }

  enforcement_level = input.restrict-ssh-enforcement-level
  enforce {
    condition     = local.compliant
    error_message = "Firewall rules must not allow SSH from an unrestricted source range such as 0.0.0.0/0 or ::/0. Replace it with specific trusted source ranges."
  }
}
