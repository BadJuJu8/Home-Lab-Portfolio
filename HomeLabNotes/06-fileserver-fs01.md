# 06-fileserver-fs01.md

## Purpose
File server build, shares, permissions model, and access behavior.

## VM Spec
- Name: FS01
- OS: Windows Server 2019
- VLAN: 10 (Servers)
- IP: 10.10.0.110
- DNS: 10.10.0.100
- Disk0: 50-60 GB (OS)
- Disk1: 80 GB (Data) mounted as S:

## Roles / Features
- File Server role installed:
  - Install-WindowsFeature FS-FileServer -IncludeManagementTools

## Storage
- Data volume:
  - Drive letter: S:
  - Path root: S:\Shares

## Shares
- Share root model: \\FS01\shares\<dept>
- Dept shares: HR, Finance, Engineering, IT, Sales, Public

## Permissions Model
- Share perms: DL_FS_Admins Full, DL_FS_<Dept>_RW Change, DL_FS_<Dept>_RO Read
- NTFS perms:
  - SYSTEM Full
  - DL_FS_Admins Full
  - DL_FS_<Dept>_RW Modify
  - DL_FS_<Dept>_RO Read/Execute

## Access Based Enumeration (ABE)
- Enabled on shares: Yes/No
- Command:
  - Set-SmbShare -Name IT -FolderEnumerationMode AccessBased

## Drive Maps
- GPO: WKS_DriveMaps_v1
- Item-level targeting on DL_FS_* groups

## Network Requirements
- OPNsense rule needed:
  - VLAN20 -> FS01 TCP 445

## Validation
- whoami /groups on client
- dir \\fs01\shares\it
- Test-NetConnection fs01 -Port 445