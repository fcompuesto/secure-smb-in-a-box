#!/usr/bin/env bash
# Replaces the allow-all MGMT (interface "lan") policy with explicit rules.
# Run from the admin port (VLAN 10). Needs an API key:  export KEY=... SECRET=...  (never commit them)
# This only ADDS rules. Disable the old "Default allow LAN to any" rules in the GUI AFTER testing.
API=https://10.10.10.1/api
post() { curl -sk -u "$KEY:$SECRET" -H 'Content-Type: application/json' -X POST "$API/$1" -d "${2:-{\}}"; echo; }

# Aliases
post firewall/alias/addItem '{"alias":{"enabled":"1","name":"INTERNAL_VLANS","type":"network","content":"10.10.20.0/24\n10.10.30.0/24\n10.10.40.0/24\n10.10.50.0/24","description":"VLANs 20-50"}}'
post firewall/alias/addItem '{"alias":{"enabled":"1","name":"SW1_MGMT","type":"host","content":"192.0.2.3","description":"SW1 management IP (VLAN 1)"}}'
post firewall/alias/reconfigure

# rule <action> <proto> <destination> <port> <description> <sequence> <log 0|1>
rule() { post firewall/filter/addRule "{\"rule\":{\"enabled\":\"1\",\"sequence\":\"$6\",\"action\":\"$1\",\"quick\":\"1\",\"interface\":\"lan\",\"direction\":\"in\",\"ipprotocol\":\"inet\",\"protocol\":\"$2\",\"source_net\":\"lan\",\"destination_net\":\"$3\",\"destination_port\":\"$4\",\"log\":\"$7\",\"description\":\"$5\"}}"; }

rule pass  TCP/UDP "(self)"          53  "MGMT DNS to firewall"        10 0
rule pass  UDP     "(self)"          123 "MGMT NTP to firewall"        11 0
rule pass  TCP     "(self)"          443 "MGMT OPNsense GUI"           12 0
rule pass  ICMP    "(self)"          ""  "MGMT ping firewall"          13 0
rule pass  TCP     SW1_MGMT          22  "MGMT SSH to SW1"             14 0
rule pass  any     INTERNAL_VLANS    ""  "MGMT admin to VLANs 20-50"   15 0
rule block any     PRIVATE_NETS      ""  "MGMT block other private"    16 1
rule pass  any     any               ""  "MGMT internet"               17 0

post firewall/filter/apply
echo "--- aliases created:"
curl -sk -u "$KEY:$SECRET" "$API/firewall/alias/searchItem?searchPhrase=INTERNAL_VLANS" | head -c 400; echo
curl -sk -u "$KEY:$SECRET" "$API/firewall/alias/searchItem?searchPhrase=SW1_MGMT" | head -c 400; echo
echo "Now check Firewall > Rules > MGMT in the GUI, test, then disable the old allow-all rules."
