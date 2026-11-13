# Phase 3: Monitoring (Wazuh)

## Objective

Collect endpoint and firewall telemetry and generate useful alerts.

## Steps

1. Deploy the Wazuh server (all-in-one) on the Servers or Management VLAN.
2. Install Wazuh agents on the domain controller and the Windows client.
3. Forward OPNsense logs to Wazuh (syslog).
4. Enable file integrity monitoring on a sensitive folder.
5. Confirm agents report in and dashboards populate.
6. Tune: disable noisy rules and keep a short note on why.

## Verification checkpoint

- [ ] Both agents show as active.
- [ ] A failed-login burst creates an alert.
- [ ] Changing a monitored file creates an alert.
- [ ] Firewall deny events appear in the dashboard.

## Break it

Stop an agent service and show how long it takes to notice. Add an alert for agent disconnects.

## Evidence to capture

Agent list, an alert detail view, a dashboard screenshot.
