# 01-architecture.md  
  
## Purpose  
Single source of truth for lab architecture: VLANs, subnets, VMs, and allowed traffic.  
  
## Domain  
- Domain: robslab.local  
- DC: DC01 (10.10.0.100)  
  
## VLANs and Subnets  
| VLAN | Name | Subnet | Gateway | Purpose |  
|------|------|--------|---------|---------|  
| 10 | Servers | 10.10.0.0/24 | 10.10.0.1 | DC, file server, infra |  
| 20 | Endpoints | 10.20.0.0/24 | 10.20.0.1 | User workstations |  
| XX | NetAdmin | <fill> | <fill> | Admin workstation |  
| XX | SecTools | <fill> | <fill> | Optional |  
  
## Core VMs  
| VM | OS | VLAN | IP | Purpose |  
|----|----|------|----|---------|  
| DC01 | Windows Server 2019 | 10 | 10.10.0.100 | AD DS, DNS, CA |  
| FS01 | Windows Server 2019 | 10 | 10.10.0.110 | SMB file server |  
| WKS01 | Windows 11 Pro | 20 | 10.20.0.101 | Domain joined endpoint |  
| SPL01 | Ubuntu Server | 10 | <fill> | Splunk |  
| NET01 | Ubuntu Desktop | NetAdmin | <fill> | Admin workstation |  
| FW01 | OPNsense | trunk | <fill> | VLAN routing, firewall |  
  
## Allowed Traffic Rules (high level)  
- VLAN20 -> VLAN10:  
- TCP 445 to FS01 (SMB)  
- TCP 636 to DC01 (LDAPS) (only if needed)  
- Clients -> DC01:  
- DNS (53)  
- Kerberos (88), LDAP (389), LDAPS (636 if used), SMB (445 for SYSVOL/NETLOGON)  
- Admin VLAN -> servers:  
- RDP (3389) only to allowed servers  
- SSH (22) only to Linux boxes  
  
## Diagrams  
- Network diagram: docs/img/<add>  
- OU diagram: docs/img/<add>  
  
## Notes / Gotchas  
- RFC1918 block rule can break access to gateway or internal services if allow rules are not above it.