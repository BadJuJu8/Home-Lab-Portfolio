# 04-active-directory.md  
  
## Purpose  
Document AD design: OU structure, group strategy, admin separation, lifecycle.  
  
## Domain Basics  
- Domain: robslab.local  
- DC: DC01 (10.10.0.100)  
- DNS: AD-integrated  
  
## OU Structure (Corp)  
- Corp  
- Admin  
- Tier0  
- Tier1  
- Tier2  
- ServiceAccounts  
- Groups  
- Servers  
- File Servers  
- Member Servers  
- App Servers  
- Management  
- Users  
- HR  
- Finance  
- Engineering  
- IT  
- Sales  
- Workstations  
- HR  
- Finance  
- Engineering  
- IT  
- Sales  
  
## Account Model  
- User account: robert.garcia  
- Admin account: robert.garcia-adm  
- Rule: never daily-drive admin accounts  
  
## Group Model  
### Naming  
- GG_* = role/identity groups (who you are)  
- DL_* = access/control groups (what you can access)  
  
### Examples  
- GG_IT_Users -> DL_FS_IT_RW  
- GG_Finance_Users -> DL_FS_Finance_RW  
- DL_LocalAdmin_Workstations  
- DL_LocalAdmin_Servers  
- DL_RDP_Workstations_Allowed  
- DL_RDP_Servers_Allowed  
  
## Joiners / Movers / Leavers (JML)  
- Joiner:  
- Mover:  
- Leaver:  
  
## Validation Commands  
- gpresult /h c:\temp\gp.html  
- whoami /groups  
- setspn -L <computer>