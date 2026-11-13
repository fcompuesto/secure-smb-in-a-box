# Phase 3: Monitoring (Wazuh)

**Status: done.** Three detections tested.

## Objective

Collect endpoint telemetry, make sure the right Windows events exist to be collected, and prove the alerts fire.

## Design

- `WZ01`: Ubuntu Server 24.04 (4 vCPU, 8 GB RAM, 100 GB disk), VLAN 20, static address, key-only SSH.
- Wazuh 4.14 all-in-one install, run inside `tmux` so a dropped connection cannot interrupt it. Admin credentials go in a password manager and the install archive is mode 600.
- The dashboard is reachable from MGMT only.
- Agents on `DC01` and `WS01`. No new firewall rules were needed: the CLIENTS-to-SERVERS rule already covers the agent ports.

## Audit policy

A domain GPO, `Security Auditing`, turns on advanced audit subcategories: credential validation, Kerberos, user and group management, process creation (with command line), directory service changes, logon, lockout, and policy change. Without these, the events Wazuh needs are never written.

## Detection tests

| Test | Windows event | Alert level | Technique |
|---|---|---|---|
| Ten failed logons on `WS01` | 4625 | 5 and 10 | Brute Force |
| New account created on `DC01` | 4720 | 8 | Account Manipulation |
| Same account added to Domain Admins | 4728 | 12 | Domain Policy Modification |

The test account was removed afterward.

## Verification checkpoint

- [x] Both agents show as active.
- [x] A failed-logon burst creates an alert.
- [x] Account creation and privileged-group changes create alerts.
- [x] `auditpol` on both machines matches the GPO.

## Lessons learned

- **Install your SSH key and test it before disabling password login.** Doing it in the other order locked out every login until the console was used to undo it.
- A VM that will not boot may simply be missing its disk from the Proxmox boot order.
- A new agent can sit in `pending` until its service is actually running.

## Next

Sysmon, OPNsense log forwarding, and a review of the CIS benchmark results.

## Break it

Stop an agent service and measure how long the dashboard takes to show it as disconnected. Then add an alert for agent disconnects.

## Evidence to capture

Agent list, an alert detail view, the audit GPO settings.
