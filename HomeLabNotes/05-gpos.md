# 05-gpos.md

## Purpose
Track GPOs, link locations, what they do, and how to validate.

## Workstation GPOs
### WKS_AuditPolicy_v1
- Link: Corp/Workstations/<Test or Dept>
- Purpose: enable audit categories for endpoints
- Key settings:
- Validation:
  - auditpol /get /category:"Logon/Logoff"
  - Event IDs: 4624, 4625, 4688

### WKS_BaselineSecurity_v2
- Link:
- Purpose: baseline hardening (firewall, LLMNR off, SMBv1 off)
- Key settings:
- Validation:
  - wf.msc
  - gpresult

### WKS_LocalAdmins_v1
- Link:
- Purpose: enforce local Administrators membership
- Method: GPP Local Users and Groups OR Restricted Groups (pick one)
- Validation:
  - net localgroup administrators

### WKS_WU_Ring0_Pilot / WKS_WU_Ring1_Broad
- Link: Test OU vs main OUs
- Purpose: update rings via policy
- Validation:
  - Windows Update UI shows managed by org

### WKS_DriveMaps_v1
- Link:
- Purpose: map drives based on group membership
- Validation:
  - gpresult /h, then check Drive Maps section
  - explorer shows mapped drive

## Server GPOs
### SRV_AuditPolicy_v1
- Link: Corp/Servers
- Purpose: enable server audit categories
- Notes: enable "Force audit policy subcategory..." setting
- Validation:
  - auditpol /get /category:"Logon/Logoff"
  - Event IDs: 4624, 4672, 4697, 4702

### SRV_BaselineSecurity_v1
- Link:
- Purpose: firewall, RDP restrictions, local admin control
- Validation:
  - Test-NetConnection <server> -Port 445/3389
  - net localgroup administrators

## Change Log
- Date:
- GPO:
- Change:
- Reason: