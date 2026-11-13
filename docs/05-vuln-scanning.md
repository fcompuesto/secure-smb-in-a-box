# Phase 5: Vulnerability Management (Greenbone)

## Objective

Scan the lab, prioritize findings, fix them, and rescan to prove improvement.

## Steps

1. Deploy Greenbone Community Edition on the Management VLAN.
2. Allow it through the firewall to scan the Servers and Staff VLANs.
3. Run an authenticated scan of the DC and the client.
4. Export the report (baseline).
5. Prioritize by severity and exposure; fix the top findings.
6. Rescan and export the report (after).

## Verification checkpoint

- [ ] Baseline and after reports exist.
- [ ] High-severity findings are reduced, with notes on what changed.

## Break it

Re-enable one fixed issue and confirm the scanner catches it.

## Evidence to capture

Before/after severity counts and a short remediation table.
