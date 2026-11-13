# Secure SMB in a Box

A hardened small-business network, built on one Proxmox server and one managed switch, documented as a repeatable blueprint you can build, break, fix, and teach.

> Built by [MaZen IT Solutions](https://www.mazenitsolutions.ca/). All IPs, hostnames, and credentials in this repo are placeholders.

## What you get

| Layer | Tooling | Outcome |
|---|---|---|
| Network & firewall | OPNsense, VLANs, managed switch | Segmented network with least-privilege rules |
| Identity | Active Directory | Central users, groups, and policy |
| Monitoring | Wazuh | Endpoint visibility and alerting |
| Resilience | Proxmox Backup Server | Backups with a **tested restore** |
| Assurance | Greenbone (OpenVAS) | Scan, fix, rescan, with evidence |
| Validation | Purple-team exercise | Attack, detect, harden |

## Architecture

![Architecture diagram](docs/diagrams/architecture.png)

*(Diagram to be added: replace with your own export. See [docs/diagrams](docs/diagrams/README.md).)*

Default VLAN plan (edit to suit):

| VLAN | Purpose | Subnet (example) |
|---|---|---|
| 10 | Management | 10.10.10.0/24 |
| 20 | Servers | 10.10.20.0/24 |
| 30 | Staff | 10.10.30.0/24 |
| 40 | Guest | 10.10.40.0/24 |
| 50 | IoT / Lab | 10.10.50.0/24 |

## Phases

Each phase stands alone and ends with a verification check and a break-it exercise.

1. [Network & firewall (OPNsense + VLANs)](docs/01-network-opnsense.md)
2. [Identity (Active Directory)](docs/02-active-directory.md)
3. [Monitoring (Wazuh)](docs/03-wazuh.md)
4. [Backups & restore (Proxmox Backup Server)](docs/04-backup-pbs.md)
5. [Vulnerability management (Greenbone)](docs/05-vuln-scanning.md)
6. [Purple-team exercise](docs/06-purple-team.md)

Also: [Lab requirements](docs/00-requirements.md) · [Sample client report](docs/client-report-template.md)

## Status

| Phase | Status |
|---|---|
| 1. Network & firewall | In progress |
| 2. Active Directory | Planned |
| 3. Wazuh | Planned |
| 4. Backups | Planned |
| 5. Greenbone | Planned |
| 6. Purple team | Planned |

## How to use this repo

- **Learners:** follow the phases in order; do the break-it exercise at the end of each.
- **Instructors:** each phase page has objectives, steps, and a checkpoint you can use as a lab handout.
- **Clients and employers:** see the [sample client report](docs/client-report-template.md) for the deliverable format.

## Safety

This is a lab. Run attack tooling (Phase 6) only inside the isolated lab VLAN. Never commit real credentials, public IPs, or client data.

## License

MIT. See [LICENSE](LICENSE).
