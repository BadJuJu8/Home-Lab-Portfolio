# 03-opnsense.md

## Purpose
Document firewall, VLAN routing, NAT, and the rule philosophy.

## Interfaces
| Interface | VLAN | IP | Purpose |
|----------|------|----|---------|
| VLAN10_Servers | 10 | 10.10.0.1 | Servers gateway |
| VLAN20_Endpoints | 20 | 10.20.0.1 | Endpoints gateway |
| <fill> | <fill> | <fill> | NetAdmin |
| WAN | - | <fill> | Internet |

## NAT
- Outbound NAT mode: Automatic / Manual
- Notes:

## Rules Philosophy
- Default deny between VLANs
- Allow only required flows
- Use aliases (RFC1918, DCs, Splunk, etc.)

## Key Rules (must have)
### Endpoints -> FS01 SMB
- Interface: VLAN20_Endpoints
- Source: VLAN20_Endpoints net
- Destination: FS01 (10.10.0.110)
- Protocol: TCP
- Port: 445

### Endpoints -> DC01 LDAPS (when testing)
- Interface: VLAN20_Endpoints
- Source: VLAN20_Endpoints net
- Destination: DC01 (10.10.0.100)
- Protocol: TCP
- Port: 636

## Common Failures and Fixes
- Could ping DC but not gateway due to RFC1918 block
- Fix: allow ICMP to gateway and allow !RFC1918 to internet above block
- Evidence: docs/img/<add>

## Logging
- Syslog to Splunk:
  - Destination:
  - Port:
  - Format: