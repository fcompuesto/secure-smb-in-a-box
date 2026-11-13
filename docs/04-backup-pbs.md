# Phase 4: Backups & Restore (Proxmox Backup Server)

## Objective

Back up the lab and prove you can restore it. A backup that has not been restored is not a backup.

## Steps

1. Deploy Proxmox Backup Server on separate storage from the VMs where possible.
2. Add it as a datastore in Proxmox VE.
3. Create backup jobs for the key VMs (OPNsense, DC, Wazuh).
4. Set retention (e.g., daily/weekly) and a prune schedule.
5. Enable encryption on the backup datastore and store the key offline.
6. Run a **full restore test** of the domain controller into an isolated network and boot it.

## Verification checkpoint

- [ ] Scheduled jobs complete successfully.
- [ ] A restored VM boots and its services work.
- [ ] Restore time is recorded.

## Break it

Delete a VM and restore it from backup. Record the time from "deleted" to "serving users again."

## Evidence to capture

Job history, retention settings, restore log with timings.
