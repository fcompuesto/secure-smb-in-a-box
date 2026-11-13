# Phase 1: Network & Firewall (OPNsense + VLANs)

## Objective

Route and firewall five VLANs through an OPNsense VM, with the switch acting as layer 2 only.

## Steps

1. Create the OPNsense VM on Proxmox with a WAN NIC and a trunk NIC.
2. Configure the managed switch: trunk to the Proxmox host, access ports per VLAN.
3. Create VLAN interfaces and DHCP scopes on OPNsense (see the VLAN plan in the README).
4. Move Proxmox management onto the management VLAN.
5. Write firewall rules (default deny between VLANs):
   - Staff → Servers: only required ports
   - Guest → Internet only
   - IoT / Lab → Internet only, no access to other VLANs
   - Management reachable only from a designated admin host
6. Enable logging on deny rules.
7. Export a sanitized config backup to `configs/` (no secrets).

## Verification checkpoint

- [ ] A guest device reaches the internet but cannot ping any internal VLAN.
- [ ] A staff device reaches the server VLAN only on allowed ports.
- [ ] Proxmox web UI is unreachable from the guest and staff VLANs.
- [ ] Firewall logs show the blocked attempts.

## Break it

Disable the Guest isolation rule. Show how a guest device can now reach a server, then restore the rule and prove the fix with the same test.

## Evidence to capture

Network diagram, rule table screenshot, blocked-traffic log excerpt.
