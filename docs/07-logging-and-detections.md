# 07-logging-and-detections.md

## Purpose
Logging sources, what events matter, and the first detections.

## Data Sources
- Windows DC logs -> Splunk:
- Windows server logs (FS01) -> Splunk:
- Windows endpoint logs -> Splunk:
- OPNsense syslog -> Splunk:

## Key Windows Event IDs
- 4624 Successful logon
- 4625 Failed logon
- 4740 Account lockout
- 4728/4729 Group membership changes
- 4732/4733 Local group membership changes
- 5136 AD object modified (DC)
- 4697 Service installed
- 4702 Scheduled task updated
- 4688 Process creation (if enabled)

## Noise Strategy
- Filter by LogonType:
  - 3 = network
  - 10 = RDP
  - 5 = service noise

## Starter Detections
1) NTLM authentication to FS01
- Trigger:
- Data:
- SPL:
- Notes:

2) RDP logon to servers
- Trigger:
- SPL:

3) Privileged group change
- Trigger:
- SPL:

4) OPNsense config change
- Trigger:
- SPL:

## Evidence Pack
- Screenshots:
- Time stamps:
- Queries: