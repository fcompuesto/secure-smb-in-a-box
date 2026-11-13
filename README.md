# Secure SMB in a Box

A hardened small-business network, built on one Proxmox server and one managed switch, documented as a repeatable blueprint you can build, break, fix, and teach.

> Built by [MaZen IT Solutions](https://www.mazenitsolutions.ca/). Addresses, names, and accounts in this repo are sanitized or placeholders. Nothing here comes from a client network.

## What you get

| Layer | Tooling | Outcome |
|---|---|---|
| Network & firewall | OPNsense, VLANs, managed switch | Segmented network, default-deny rules, every rule logged |
| Identity | Active Directory | Central users, groups, and baseline policy |
| Monitoring | Wazuh | Endpoint visibility and tested detections |
| Resilience | Proxmox Backup Server | Backups with a **tested restore** |
| Assurance | Greenbone (OpenVAS) | Scan, fix, rescan, with evidence |
| Validation | Purple-team exercise | Attack, detect, harden |

## Architecture

![Architecture diagram](docs/diagrams/architecture.png)

*(Diagram to be added. See [docs/diagrams](docs/diagrams/README.md).)*

The switch is layer 2 only. OPNsense, running as a VM on the Proxmox host, does all inter-VLAN routing and filtering so every rule is visible and logged.

| VLAN | Name | Purpose | Subnet |
|---|---|---|---|
| 10 | MGMT | Proxmox, switch, out-of-band management | 10.10.10.0/24 |
| 20 | SERVERS | Domain controller, Wazuh, backups | 10.10.20.0/24 |
| 30 | CLIENTS | Staff workstations | 10.10.30.0/24 |
| 40 | LAB | Isolated attack and vulnerable-VM lab | 10.10.40.0/24 |
| 50 | HOME-IOT | Home, IoT, and guest devices | 10.10.50.0/24 |
| 99 | BLACKHOLE | Unused ports and the trunk native VLAN | none |

## Phases

Each phase ends with a verification checkpoint and a break-it exercise.

1. [Network & firewall (OPNsense + VLANs)](docs/01-network-opnsense.md)
2. [Identity (Active Directory)](docs/02-active-directory.md)
3. [Monitoring (Wazuh)](docs/03-wazuh.md)
4. [Backups & restore (Proxmox Backup Server)](docs/04-backup-pbs.md)
5. [Vulnerability management (Greenbone)](docs/05-vuln-scanning.md)
6. [Purple-team exercise](docs/06-purple-team.md)

Also: [Lab requirements](docs/00-requirements.md) · [Findings tracker](docs/findings.md) · [Configs](configs/README.md) · [Sample client report](docs/client-report-template.md)

## Status

| Phase | Status |
|---|---|
| 1. Network & firewall | Done (iDRAC move to MGMT deferred) |
| 2. Active Directory | Done |
| 3. Wazuh | Done (three detections tested) |
| 4. Backups | In progress |
| 5. Greenbone | Planned |
| 6. Purple team | Planned |

21 findings are tracked in [docs/findings.md](docs/findings.md), with before/after evidence for each closed item.

## How to use this repo

- **Learners:** follow the phases in order and do the break-it exercise at the end of each.
- **Instructors:** each phase page has objectives, steps, and a checkpoint you can use as a lab handout.
- **Clients and employers:** see the [sample client report](docs/client-report-template.md) for the deliverable format.

## Safety

This is a lab. Run attack tooling only inside the isolated LAB VLAN. Never commit real credentials, public IPs, or client data.

## License

MIT. See [LICENSE](LICENSE).
