# Enterprise Cybersecurity Homelab

This project is a corporate-style homelab built to develop hands-on skills in virtualization, network segmentation, Active Directory, Group Policy, file services, Linux administration, and security monitoring. The environment is hosted on Proxmox and includes OPNsense for routing and firewalling, a Windows domain built around Active Directory and DNS, department-based access control, Ubuntu systems for administration and Splunk, and centralized logging for early detection engineering.

## At a Glance

- **Hypervisor:** Proxmox VE
- **Firewall/Router:** OPNsense
- **Directory Services:** Active Directory, DNS
- **Endpoint Management:** Group Policy
- **File Services:** Department-based shares on FS-01
- **Linux Systems:** Ubuntu NetAdmin, Ubuntu Splunk host
- **SIEM:** Splunk
- **Network Design:** VLAN segmentation for Servers, Endpoints, NetAdmin, and SecTools
- **Focus Areas:** Identity, segmentation, hardening, centralized logging, detection engineering

## Architecture Summary

The lab is built on Proxmox and designed to simulate a small corporate environment. OPNsense provides routing and firewall control. Core Windows services include Active Directory, DNS, Group Policy, and file services. The network is segmented into dedicated VLANs for servers, user endpoints, administrative systems, and security tooling. Ubuntu systems support Linux administration and Splunk-based centralized logging.

## Technologies Used

- Proxmox VE
- OPNsense
- Windows Server
- Active Directory Domain Services
- DNS
- Group Policy
- Windows 11
- Ubuntu Server / Ubuntu Desktop
- Splunk
- PowerShell

## Key Capabilities

- Built a Proxmox-based virtualization environment for multi-VM enterprise lab simulation
- Deployed OPNsense as the primary router and firewall
- Designed VLAN-based segmentation for infrastructure, endpoints, administration, and security tooling
- Built an Active Directory domain with centralized identity and DNS
- Organized users, systems, and departments through a structured OU design
- Applied Group Policy baselines for workstation and server control
- Deployed a file server with department-based shares and mapped drives
- Added Ubuntu systems for mixed-platform administration and security tooling
- Centralized logs into Splunk using firewall telemetry and Windows Universal Forwarders
- Developed early detections such as repeated failed logon activity

## Network Segmentation

| VLAN ID | Name      | Subnet       | Gateway   | Purpose                               |
| ------: | --------- | ------------ | --------- | ------------------------------------- |
|      10 | Servers   | 10.10.0.0/24 | 10.10.0.1 | Domain controller, file server        |
|      20 | Endpoints | 10.20.0.0/24 | 10.20.0.1 | User workstations                     |
|      50 | NetAdmin  | 10.50.0.0/24 | 10.50.0.1 | Administrative workstation            |
|      60 | SecTools  | 10.60.0.0/24 | 10.60.0.1 | Security tools and monitoring systems |
## Project Phases

- 00-Architecture
- 01-Proxmox Foundation, Initial Constraints, and Early Design Decision
- 02-OPNsense Deployment and Early Network Foundation
- 03-VLAN Design, Segmentation Strategy, and Internal Network Trust Boundaries
- 04-Active Directory and DNS Foundation in a Segmented Network
- 05-OU Structure, Department Design, User Provisioning, and Naming Standards
- 06-Group Policy Design, Baseline Security, and Centralized Endpoint Control
- 07-File Server Deployment, Department Shares, and Drive Mapping Through Group Policy
- 08-Linux Systems, Cross Platform Administration, and Early Trust Integration Challenges
- 09-Splunk Deployment, Centralized Logging, and Early Detection Engineering
## Lessons Learned

- Infrastructure design is heavily shaped by hardware constraints
- Network segmentation is much more valuable when trust boundaries are deliberate
- Active Directory depends heavily on DNS and clean directory structure
- Group Policy becomes far more effective when OU design is intentional
- File access control is where identity, permissions, and user experience intersect
- Mixed Windows and Linux environments introduce more realistic trust and integration challenges
- Centralized logging is only useful when data sources, forwarding, and parsing are engineered correctly
