#!/usr/bin/env bash
# Creates the PRIVATE_NETS alias and the default-deny firewall rules via the OPNsense API.
# Usage: export KEY=... SECRET=...   (API key/secret from System > Access > Users; never commit them)
# API points at the GUI through an SSH tunnel: ssh -L 8443:10.10.10.1:443 root@<pve2>
# Interface names: opt1=SERVERS(20) opt2=CLIENTS(30) opt3=LAB(40) opt4=HOME-IOT(50)
API=https://localhost:8443/api
post() { curl -sk -u "$KEY:$SECRET" -H 'Content-Type: application/json' -X POST "$API/$1" -d "${2:-{\}}"; echo; }

post firewall/alias/addItem '{"alias":{"enabled":"1","name":"PRIVATE_NETS","type":"network","content":"10.0.0.0/8\n172.16.0.0/12\n192.168.0.0/16","description":"RFC1918"}}'
post firewall/alias/reconfigure

# rule <interface> <action> <proto> <source> <destination> <port> <description> <sequence>
rule() { post firewall/filter/addRule "{\"rule\":{\"enabled\":\"1\",\"sequence\":\"$8\",\"action\":\"$2\",\"quick\":\"1\",\"interface\":\"$1\",\"direction\":\"in\",\"ipprotocol\":\"inet\",\"protocol\":\"$3\",\"source_net\":\"$4\",\"destination_net\":\"$5\",\"destination_port\":\"$6\",\"description\":\"$7\"}}"; }

for p in "opt3 LAB 100" "opt4 HOME-IOT 200" "opt1 SERVERS 300"; do
  set -- $p
  rule $1 pass  TCP/UDP $1 "(self)"     53 "$2 DNS to firewall" $(($3+1))
  rule $1 block any     $1 PRIVATE_NETS "" "$2 block internal"  $(($3+2))
  rule $1 pass  any     $1 any          "" "$2 internet"        $(($3+3))
done

rule opt2 pass  TCP/UDP opt2 "(self)"     53 "CLIENTS DNS to firewall" 401
rule opt2 pass  any     opt2 opt1         "" "CLIENTS to SERVERS"      402
rule opt2 block any     opt2 PRIVATE_NETS "" "CLIENTS block internal"  403
rule opt2 pass  any     opt2 any          "" "CLIENTS internet"        404

post firewall/filter/apply
