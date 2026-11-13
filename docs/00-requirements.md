# Lab Requirements

## Hardware (reference build)

- Proxmox VE host with 4 NICs, ~80 GB RAM, ~4 TB storage
- Managed L2 switch with 802.1Q VLAN support (reference: Cisco 2960X)
- ISP modem/router (placed in front of OPNsense)
- A spare laptop or PC as a test client

Minimum to follow along: any host that runs Proxmox with 32 GB RAM and one managed switch.

## Software

- Proxmox VE, OPNsense, Windows Server (evaluation), Windows client (evaluation)
- Wazuh, Proxmox Backup Server, Greenbone Community Edition
- A Linux attacker VM for Phase 6 (e.g., Kali)

## Conventions

- Document in Markdown; diagrams exported to `docs/diagrams/`.
- Take a Proxmox snapshot before every phase.
- Record verification evidence (screenshots, command output) under `docs/evidence/` with secrets redacted.
