# Phase 1: Network & Firewall (OPNsense + VLANs)

**Status: done.** Exact configs are in [`configs/`](../configs/README.md).

## Objective

Route and firewall five VLANs through an OPNsense VM, with the switch acting as layer 2 only, and move Proxmox management onto its own VLAN.

## Design

- Proxmox host on a 4-NIC server. One NIC is the WAN side (`vmbr0`, to the ISP modem); another is a VLAN trunk (`vmbr1`, VLAN-aware) to the switch.
- OPNsense VM: 2 vCPU, 4 GB RAM, 20 GB disk, VirtIO NICs, Proxmox NIC firewall off so the trunk is not filtered twice.
- VLANs: 10 MGMT, 20 SERVERS, 30 CLIENTS, 40 LAB, 50 HOME-IOT, 99 BLACKHOLE (see the README table).
- Trunk native VLAN is 99, a dead-end VLAN, so untagged traffic goes nowhere. Unused switch ports sit in VLAN 99, shut down.
- Kea DHCP per VLAN; the GUI is reached through an SSH tunnel and is not exposed to the upstream network.

## Steps

1. Review the host and switch before changing anything (interfaces, MAC table, CDP neighbors). Leave live ports alone.
2. Add the VLAN-aware bridge without touching the existing one, so management access is never at risk. ([`pve2-network-additions.txt`](../configs/pve2-network-additions.txt))
3. Apply the switch config with `reload in 10` armed as a safety net, then confirm none is pending and save. ([`sw1-config-applied.txt`](../configs/sw1-config-applied.txt))
4. Create the OPNsense VM with the WAN virtual NIC **link-down** until interfaces are assigned, then reconnect it last.
5. Assign VLAN interfaces, enable Kea DHCP on each, and disable hardware offload.
6. Build default-deny rules through the API so the build is repeatable. ([`opnsense-api-setup.sh`](../configs/opnsense-api-setup.sh))
7. Add a dedicated admin port in VLAN 10, then move Proxmox management to the VLAN using a script with an automatic rollback. ([`pve2-cutover.sh`](../configs/pve2-cutover.sh))
8. Enable the Proxmox host firewall: default deny, MGMT only. ([`pve2-firewall.sh`](../configs/pve2-firewall.sh))
9. Replace the allow-all MGMT policy with eight explicit, logged rules. ([`opnsense-mgmt-rules.sh`](../configs/opnsense-mgmt-rules.sh))
10. Harden access: key-only SSH on Proxmox and OPNsense, switch HTTP and Smart Install off, VTP transparent.

## Firewall policy (first match wins)

| Interface | Rule order |
|---|---|
| LAB, HOME-IOT, SERVERS | DNS to the firewall, block private ranges, allow internet |
| CLIENTS | DNS to the firewall, allow to SERVERS, block private ranges, allow internet |
| MGMT | DNS, NTP, GUI, and ping to the firewall; SSH to the switch; allow to VLANs 20-50; **block and log** other private ranges; allow internet |

`PRIVATE_NETS` is the three RFC 1918 ranges. Blocking it after the specific allows gives each VLAN internet access and nothing else.

## Verification checkpoint

- [x] A CLIENTS device gets an address, reaches the internet and SERVERS, and cannot reach MGMT or the upstream LAN.
- [x] A LAB device reaches the internet only. VLANs 10, 20, 30, the modem, and the Proxmox host are all blocked.
- [x] From OPNsense, a connection to the Proxmox GUI sourced from the CLIENTS gateway times out, and one sourced from MGMT succeeds.
- [x] The blocked MGMT-to-upstream attempt appears in the firewall log as `MGMT block other private`.
- [x] Switch ports 4786, 80, and 443 refuse connections (Smart Install and HTTP management are off).
- [x] Key login works on Proxmox and OPNsense; with public-key auth disabled, login fails.

## Lessons learned

1. **A fresh OPNsense image is a rogue DHCP server.** It defaults to a LAN address with DHCP on the first NIC it sees. Keep the WAN link down until interfaces are assigned.
2. **An empty alias fails silently.** The block rule matched nothing and traffic leaked until the alias was populated. Verify aliases after creating them.
3. **A stale address on a parent interface breaks VLANs.** Replies went out untagged, so ARP worked but ping did not.
4. **Two DHCP servers cannot share a port.** A leftover dnsmasq range stopped Kea from binding.
5. **A VPN on the test laptop invalidates isolation tests.** Disable every other interface and check the route first.
6. **Arm a rollback before any network change**, and change `/etc/hosts` together with the host address.
7. **Check the prompt before server-side commands.** A hardening command was once run on the workstation by mistake. Nothing changed, but it is easy to do.

## Break it

Disable the CLIENTS "block private ranges" rule. Show that a client can now reach the MGMT VLAN, then restore the rule and prove the fix with the same test.

## Evidence to capture

Network diagram, rule table, blocked-traffic log excerpt, switch trunk output.
