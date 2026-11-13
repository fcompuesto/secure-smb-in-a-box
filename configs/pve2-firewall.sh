#!/bin/bash
# Enables the Proxmox datacenter + node firewall on pve2: default-deny inbound,
# only VLAN 10 (10.10.10.0/24) may reach SSH (22), the GUI (8006) and ping.
# Run ON pve2 from a session that arrives over VLAN 10 (admin port Gi1/0/3).
# A rollback timer disables the firewall after 300 s unless cancelled.
set -u
CL=/etc/pve/firewall/cluster.fw
HOST=/etc/pve/local/host.fw

# Refuse to overwrite an existing firewall config
if [ -s "$CL" ] || [ -s "$HOST" ]; then
  echo "A firewall config already exists:"; ls -l "$CL" "$HOST" 2>/dev/null
  echo "Aborting so nothing is overwritten. Review it first."; exit 1
fi
mkdir -p /etc/pve/firewall /root/pve-firewall-backup
cp -a /etc/pve/firewall/. /root/pve-firewall-backup/ 2>/dev/null

# Rollback: disable the firewall and stop it
cat > /root/fw-rollback.sh <<'EOS'
#!/bin/bash
printf '[OPTIONS]\nenable: 0\n' > /etc/pve/firewall/cluster.fw
rm -f /etc/pve/local/host.fw
/usr/sbin/pve-firewall stop
EOS
chmod +x /root/fw-rollback.sh
systemctl stop fw-rollback.timer 2>/dev/null
systemd-run --on-active=300 --unit=fw-rollback /root/fw-rollback.sh >/dev/null
echo "Rollback armed (300 s). Cancel with:  systemctl stop fw-rollback.timer"

# Datacenter firewall: default deny in, allow VLAN 10 to SSH, GUI, ping
cat > "$CL" <<'EOC'
[OPTIONS]
enable: 1
policy_in: DROP
policy_out: ACCEPT

[IPSET management]
10.10.10.0/24 # VLAN 10 management

[RULES]
IN SSH(ACCEPT) -source +management -log nolog # SSH from VLAN 10
IN ACCEPT -p tcp -dport 8006 -source +management -log nolog # Web GUI from VLAN 10
IN Ping(ACCEPT) -source +management -log nolog # ICMP from VLAN 10
EOC

# Node firewall: enable and log dropped inbound packets
cat > "$HOST" <<'EOH'
[OPTIONS]
enable: 1
log_level_in: info
EOH

echo "Waiting for pve-firewall to apply (up to 20 s)..."
sleep 20
echo "=== CHECKS ==="
pve-firewall status
pve-firewall compile 2>/dev/null | grep -E 'dport (22|8006)|management' | head -8
ping -c 2 -W 2 10.10.10.1 >/dev/null && echo "OK  gateway reachable" || echo "FAIL gateway"
ping -c 2 -W 2 1.1.1.1    >/dev/null && echo "OK  internet"          || echo "FAIL internet"
systemctl is-active pveproxy pvedaemon
echo
echo "If these checks are OK and this session is alive, also load https://10.10.10.5:8006 in the browser,"
echo "then cancel the rollback:  systemctl stop fw-rollback.timer"
echo "If anything fails, do nothing: the firewall switches itself off in about 5 minutes."
