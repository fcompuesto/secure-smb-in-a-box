# Phase 6: Purple-Team Exercise

## Objective

Run a simple, controlled attack, confirm your monitoring detects it, then harden the gap.

## Rules of engagement

- Lab VLAN only. Written scope before you start.
- Snapshot all targets first.
- Never point tooling at anything you do not own.

## Steps

1. Pick two or three simple techniques (e.g., password spraying against the lab domain, a suspicious PowerShell command, a port scan).
2. Map each to a MITRE ATT&CK technique ID.
3. Run each from the attacker VM.
4. Record whether Wazuh and the firewall logs detected it, and how quickly.
5. For each miss, add a detection rule or hardening control.
6. Re-run the technique and confirm it is now detected or blocked.

## Results table (template)

| Technique | ATT&CK ID | Detected? | Time to detect | Fix applied | Re-test |
|---|---|---|---|---|---|
| | | | | | |

## Verification checkpoint

- [ ] Every technique has a before and after result.
- [ ] At least one detection gap was found and closed.

## Evidence to capture

Alert screenshots, the results table, a short write-up of lessons learned.
