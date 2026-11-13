# Phase 2: Identity (Active Directory)

## Objective

Stand up a small AD domain with realistic users, groups, and baseline policy.

## Steps

1. Create a Windows Server VM on the Servers VLAN and promote it to a domain controller.
2. Set a static IP and point DNS to the DC.
3. Create OUs (e.g., Staff, Admins, Computers) and security groups.
4. Add a handful of test users with a documented naming scheme.
5. Join a Windows client on the Staff VLAN.
6. Apply baseline Group Policy: password policy, account lockout, screen lock, disable unused features.
7. Open only the firewall ports the client needs to reach the DC.

## Verification checkpoint

- [ ] A standard user can log in to the client with domain credentials.
- [ ] A standard user cannot install software or open admin tools.
- [ ] Lockout triggers after repeated failed logins.

## Break it

Add a user to a privileged group by mistake and show what that user can now do. Then remove the access and audit it.

## Evidence to capture

OU structure screenshot, GPO settings report, lockout test result.
