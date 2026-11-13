# Phase 2: Identity (Active Directory)

**Status: done.**

## Objective

Stand up a small AD domain with realistic users, groups, and baseline policy, reachable only through the firewall rules from Phase 1.

## Design

- `DC01`: Windows Server 2022 (evaluation), VLAN 20, static address, VirtIO disk and NIC (driver loaded during setup), VirtIO guest tools installed.
- Forest `ad.example.com`, NetBIOS `LAB`, 2016 functional level. DNS forwards to the OPNsense gateway.
- `WS01`: Windows 11 Enterprise (evaluation) with a virtual TPM, VLAN 30, joined to the domain.
- Kea on the CLIENTS VLAN hands out the domain controller as the only DNS server.

## Structure

- OU `Company` with `Users`, `Computers`, `Servers`, `Groups`, and `Admins`.
- Groups `GG-IT-Admins`, `GG-Staff`, `GG-Finance`.
- Three standard staff users and a **separate admin account** for administrative work.
- `redircmp` sends new computer accounts to `OU=Computers` so policy applies from the first login.

## Policy

- Password policy: 14 characters minimum, complexity on, lockout after 5 attempts for 30 minutes.
- GPO `Workstation Baseline`, linked to `OU=Computers`: LLMNR off, 15-minute inactivity lock, SMBv1 server off.

## Verification checkpoint

- [x] `WS01` resolves the domain through `DC01`, and TCP 389 is reachable with no new firewall rule.
- [x] A standard user logs in with domain credentials.
- [x] `gpupdate` succeeds and the GPO appears under Applied GPOs.
- [x] Registry checks on `WS01` confirm LLMNR is off and the inactivity timeout is 900 seconds.
- [x] RDP works from the MGMT VLAN for members of `GG-Staff`.

## Known gaps (tracked, not hidden)

- No reverse DNS zone yet, so `nslookup` shows an unknown name.
- `WS01` uses a DHCP address; a reservation is the fix.
- RDP is open to the lab for convenience. In production, limit it to MGMT.
- Snapshots are not backups. Phase 4 adds real backups.

## Lessons learned

- Put the DC address in the DHCP **DNS servers** field, not the dynamic-DNS field.
- Disable automatic DHCP option collection when you set options by hand.

## Break it

Add a standard user to a privileged group by mistake and show what that user can now do. Then remove the access and review the change in the logs. (Phase 3 detects exactly this.)

## Evidence to capture

OU structure screenshot, GPO settings report, lockout test result.
