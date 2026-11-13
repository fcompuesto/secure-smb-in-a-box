# Phase 4: Backups & Restore (Proxmox Backup Server)

**Status: in progress.** The backup server VM and datastore exist; the backup user, token, and two-factor setup are being finished.

## Objective

Back up the lab and prove you can restore it. A backup that has not been restored is not a backup.

## Why this phase matters

Snapshots live on the same disk as the VMs and RAID is not a backup, so until this phase is complete the lab has no real recovery path. That gap is tracked as a High finding in [findings.md](findings.md).

## Steps

1. Deploy Proxmox Backup Server, ideally with storage separate from the VMs.
2. Create the datastore and a dedicated backup user and API token with least privilege; enable two-factor authentication on admin accounts.
3. Add it as a storage target in Proxmox VE.
4. Create backup jobs for the key VMs: the OPNsense firewall, the domain controller, the workstation, and Wazuh.
5. Set retention and a prune schedule.
6. Enable encryption and store the key offline.
7. Run a **full restore test** of the domain controller into an isolated network and boot it.

## Verification checkpoint

- [ ] Scheduled jobs complete successfully.
- [ ] A restored VM boots and its services work.
- [ ] Restore time is recorded.

## Break it

Delete a VM and restore it from backup. Record the time from "deleted" to "serving users again."

## Evidence to capture

Job history, retention settings, restore log with timings.
