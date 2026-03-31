### Purpose  
Single source of truth for lab architecture: VLANs, subnets, VMs, and allowed traffic.  
## Domain  
- Domain: robslab.local  
- DC: DC01 (10.10.40.100)  
## VLANs and Subnets  
| VLAN | Name      | Subnet       | Gateway   | Purpose                |     |
| ---- | --------- | ------------ | --------- | ---------------------- | --- |
| 10   | Servers   | 10.10.0.0/24 | 10.10.40.1 | DC, file server, infra |     |
| 20   | Endpoints | 10.20.0.0/24 | 10.20.40.1 | User workstations      |     |
| 50   | NetAdmin  | 10.50.0.0/24 | 10.50.40.1 | Admin workstation      |     |
| 60   | SecTools  | 10.60.0.0/24 | 10.60.40.1 | Security Tools         |     |

## Core VMs  
| VM       | OS                  | VLAN     | IP          | Purpose                |     |
| -------- | ------------------- | -------- | ----------- | ---------------------- | --- |
| DC01     | Windows Server 2019 | 10       | 10.10.40.100 | AD DS, DNS, CA         |     |
| FS01     | Windows Server 2019 | 10       | 10.10.40.110 | SMB file server        |     |
| WKS01    | Windows 11 Pro      | 20       | 10.20.40.101 | Domain joined endpoint |     |
| SPL01    | Ubuntu Server       | 10       | 10.60.40.100 | Splunk                 |     |
| netAdmin | Ubuntu Desktop      | NetAdmin | 10.50.40.100 | Admin workstation      |     |
| FW01     | OPNsense            | trunk    | 10.         | VLAN routing, firewall |     |
  
## Allowed Traffic Rules (high level)  
![[Pasted image 20260319182515.png]]
![[Pasted image 20260319183017.png]]
![[Pasted image 20260319183102.png]]
![[Pasted image 20260319182421.png]]

  
