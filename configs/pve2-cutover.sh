#!/bin/bash
# Moves Proxmox management from the modem LAN (vmbr0, 192.0.2.132) to VLAN 10 (vmbr1.10, 10.10.10.5).
# Run ON pve2, from a session that arrives over VLAN 10 (admin port Gi1/0/3).
# Arms a rollback timer first: unless cancelled within 180 s, the old config is restored.
set -u
for f in interfaces hosts resolv.conf; do
  [ -f /root/$f.pre-cutover ] || [ -f /root/${f%.conf}.pre-cutover ] || { echo "Missing backup for $f, aborting"; exit 1; }
done

cat > /root/rollback.sh <<'EOS'
#!/bin/bash
cp /root/interfaces.pre-cutover /etc/network/interfaces
cp /root/hosts.pre-cutover /etc/hosts
cp /root/resolv.conf.pre-cutover /etc/resolv.conf
ifreload -a
systemctl restart pveproxy pvedaemon
EOS
chmod +x /root/rollback.sh
nohup bash -c 'sleep 180; /root/rollback.sh' > /root/rollback.log 2>&1 &
echo $! > /root/rollback.pid
echo "Rollback armed (PID $(cat /root/rollback.pid)). Cancel within 180 s with:  kill \$(cat /root/rollback.pid)"

# 1. interfaces: vmbr0 keeps no address; vmbr1.10 gets the gateway
sed -i -e 's/^iface vmbr0 inet static/iface vmbr0 inet manual/' \
       -e '/^[[:space:]]*address 192\.168\.1\.132\/24[[:space:]]*$/d' \
       -e '/^[[:space:]]*gateway 192\.168\.1\.254[[:space:]]*$/d' \
       -e '/^[[:space:]]*address 10\.10\.10\.5\/24[[:space:]]*$/a\        gateway 10.10.10.1' \
       -e 's/#Proxmox mgmt on VLAN 10 (no gateway yet)/#Proxmox mgmt on VLAN 10/' /etc/network/interfaces

# 2. hosts and DNS
sed -i 's/192\.168\.1\.132/10.10.10.5/g' /etc/hosts
sed -i '/^nameserver/d' /etc/resolv.conf
echo "nameserver 10.10.10.1" >> /etc/resolv.conf

echo "--- /etc/network/interfaces (changed parts)"; grep -nE 'vmbr0|vmbr1\.10|address|gateway' /etc/network/interfaces
echo "--- /etc/hosts"; cat /etc/hosts
echo "--- /etc/resolv.conf"; cat /etc/resolv.conf

# 3. apply
ifreload -a
sleep 3
systemctl restart pveproxy pvedaemon

echo "=== CHECKS ==="
ip -br addr show vmbr0; ip -br addr show vmbr1.10
ip route | head -5
ping -c 2 -W 2 10.10.10.1 >/dev/null && echo "OK  gateway 10.10.10.1" || echo "FAIL gateway"
ping -c 2 -W 2 1.1.1.1    >/dev/null && echo "OK  internet by IP"   || echo "FAIL internet by IP"
ping -c 2 -W 2 google.com >/dev/null && echo "OK  DNS"              || echo "FAIL DNS"
getent hosts "$(hostname)"
systemctl is-active pveproxy pvedaemon
echo
echo "If every check is OK and this session is still alive: cancel the rollback NOW:  kill \$(cat /root/rollback.pid)"
echo "If anything FAILED, do nothing: the old config returns in about 3 minutes."
