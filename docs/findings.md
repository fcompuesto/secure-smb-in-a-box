# Findings and Remediation Tracker

Sanitized from the working lab notes. Addresses in the 192.0.2.0/24 range are documentation placeholders for the upstream ISP-side network.

| # | Finding | Severity | Status | Action |
|---|---|---|---|---|
| 1 | SW1 runs IOS 15.2(2)E3, which is old and outdated | High | Open | Check for a newer image (may need a Cisco support contract). Document if not available. |
| 2 | Smart Install (vstack) is enabled by default on this switch family and is vulnerable on older IOS (CVE-2018-0171) | High | Closed 2026-10-27 | `no vstack` applied. Verified from the network: `nc -zv -w 3 192.0.2.3 4786` returns Connection refused. |
| 3 | SSH on SW1 only offers legacy key exchange (group1/group14-sha1, ssh-rsa host key) | Medium | Open | Regenerate RSA key (`crypto key generate rsa modulus 2048`), `ip ssh version 2`, update IOS |
| 4 | HTTP/HTTPS management server may be enabled on SW1 | Medium | Closed 2026-10-27 | `no ip http server`, `no ip http secure-server` applied. Verified: ports 80 and 443 both Connection refused. |
| 5 | VTP mode not yet confirmed transparent | Low | Closed 2026-10-29 | `vtp mode transparent` applied. Verified `show vtp status` (Transparent) and the line in both running and startup config. |
| 6 | Flat network: the upstream LAN carries every existing device in one VLAN | Medium | In progress | OPNsense now routes and filters VLANs 10-50 (see build log). Migrate remaining devices into VLANs one at a time. |
| 7 | Proxmox management currently on the modem LAN (192.0.2.132) | Medium | Closed 2026-10-27 | Moved to `vmbr1.10` (10.10.10.5, gateway 10.10.10.1). Host has no IPv4 on vmbr0. Verified default route and GUI at https://10.10.10.5:8006. |
| 8 | Backups: no Proxmox Backup Server yet; RAID is not backup | High | Planned | PBS on a separate disk/NAS, tested restore, then an encrypted offsite copy |
| 9 | Unlabeled cable found on the trunk port with no matching server NIC | Info | Resolved | Cable moved; origin still unconfirmed. Document cable labeling. |

Mitigations that cost nothing (items 2, 4, 5) should be applied first and verified with a before/after screenshot.

## New findings from the OPNsense build (2026-10)
| # | Finding | Severity | Status | Action |
|---|---|---|---|---|
| 10 | A freshly booted OPNsense live image defaults to LAN 192.0.2.1 with DHCP on the NIC it sees first. Attached to the home network it is a rogue DHCP server. | High (if repeated) | Mitigated | Keep the WAN vNIC link down (`link_down=1`) until interfaces are assigned. |
| 11 | A leftover dnsmasq DHCP range from console setup held UDP 67 and stopped Kea from binding on every VLAN | Medium | Closed | Removed the dnsmasq range. Verified with `sockstat -4 -l | grep 67` that only `kea-dhcp4` listens. |
| 12 | A firewall alias with empty content silently makes the rules that use it match nothing (block rule leaked traffic) | Medium | Closed | Alias `PRIVATE_NETS` populated with the three RFC1918 ranges. Verify aliases after creating them. |
| 13 | A test client with a VPN or second NIC sends traffic around the firewall, which invalidated early isolation tests | Info | Closed | Isolation tests must run with every other interface and VPN disabled. Check `route get <target>` first. |
| 14 | OPNsense root SSH with password login enabled during the build | Medium | Closed 2026-10-28 | SSH key-only (ed25519, passphrase-protected), listening on MGMT only, password login off. Verified: key login works; `ssh -o PubkeyAuthentication=no` returns Permission denied (publickey). Temporary API keys deleted after use. |
| 15 | Proxmox host kept a global IPv6 address on vmbr0 (SLAAC from the modem), exposing SSH and the GUI on the modem side with no host firewall | High | Closed 2026-10-27 | `net.ipv6.conf.vmbr0.disable_ipv6=1` live, plus `post-up` line in the vmbr0 block. Verified `ip -br addr show vmbr0` shows no addresses. |
| 16 | Proxmox host firewall not enabled | Medium | Closed 2026-10-27 | Datacenter + node firewall enabled, default-deny inbound, IPSet `management` (10.10.10.0/24) allowed to SSH, GUI, ping. Verified from OPNsense: `nc -s 10.10.30.1 10.10.10.5 8006` times out, `nc -s 10.10.10.1 ...` succeeds. |
| 17 | iDRAC not yet on the management VLAN | Medium | Open, deferred by choice (needs on-site cabling) | Move to Gi1/0/2 (VLAN 10), static IP in 10.10.10.0/24, change default credentials |
| 18 | Proxmox uses the Enterprise update repository without a subscription, so package updates fail | Low | Closed 2026-10-29 | Enterprise repo disabled, No-Subscription enabled. Verified `apt update` completes with no 401 errors. |
| 19 | MGMT (VLAN 10) used a default allow-all rule, so admin hosts could reach the modem and every other device on the upstream LAN | Medium | Closed 2026-10-28 | Replaced with 8 explicit rules (DNS, NTP, GUI, ping to firewall; SSH to SW1; admin to VLANs 20-50; block other private ranges with logging; internet). Old default rules disabled. Verified: ping to modem 192.0.2.254 blocked and logged as `MGMT block other private`; DNS, internet and SSH to SW1 work. |
| 20 | Proxmox root SSH allowed password login | Medium | Closed 2026-10-28 | `/etc/ssh/sshd_config.d/10-hardening.conf`: PasswordAuthentication no, PermitRootLogin prohibit-password, KbdInteractiveAuthentication no. Verified key login works and password attempts are refused. |
| 21 | Proxmox host had 191 pending package updates (including kernel and security fixes) | Medium | Closed 2026-10-29 | `apt dist-upgrade` completed (second run: nothing left), kernel 7.0.14-26-pve after reboot. Post-reboot checks all passed: GUI, OPNsense autostart, gateway/internet, DHCP, no IPv6 on vmbr0 (post-up line works at boot), host firewall running. |
