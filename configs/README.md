# Configs

The exact configuration applied in the lab, sanitized for publication.

| File | What it does |
|---|---|
| `sw1-config-applied.txt` | Switch VLANs, trunk, access and unused ports |
| `pve2-network-additions.txt` | VLAN-aware bridge and management interface on Proxmox |
| `pve2-interfaces-pre-cutover.txt` | Proxmox network config before management moved to VLAN 10 |
| `pve2-cutover.sh` | Moves Proxmox management to VLAN 10 with an automatic rollback timer |
| `pve2-firewall.sh` | Enables the Proxmox host firewall (default deny, MGMT only) with a rollback timer |
| `opnsense-api-setup.sh` | Creates the `PRIVATE_NETS` alias and the default-deny rules through the OPNsense API |
| `opnsense-mgmt-rules.sh` | Replaces the allow-all MGMT policy with explicit, logged rules |

## Sanitization notes

- `192.0.2.x` is a documentation range standing in for the upstream (ISP-side) network.
- API keys and secrets are never stored. Scripts read them from the `KEY` and `SECRET` environment variables.
- Scripts that change networking arm an automatic rollback first. Read them before running, and test from an admin port you can reach out of band.
- Hostnames follow the lab (`pve2`, `SW1`); change them to match your environment.
