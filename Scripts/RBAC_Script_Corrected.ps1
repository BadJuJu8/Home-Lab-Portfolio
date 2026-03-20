<# 
Fix-RBAC-FileShareGroups.ps1

What it does (idempotent):
1) Removes GG_<Dept>_Users from BOTH DL_FS_<Dept>_RO and DL_FS_<Dept>_RW
   (prevents "everyone gets RW" mistakes)
2) Ensures role groups exist for each department:
   GG_<Dept>_Staff and GG_<Dept>_Lead
3) Nests role groups into DL groups:
   GG_<Dept>_Staff -> DL_FS_<Dept>_RO
   GG_<Dept>_Lead  -> DL_FS_<Dept>_RW
4) IT mapping uses existing roles:
   GG_IT_Helpdesk    -> DL_FS_IT_RO
   GG_IT_ServerAdmins-> DL_FS_IT_RW

Run on DC01 in an elevated PowerShell with RSAT/AD module.
Dry-run first (default). Use -Execute to make changes.
#>

[CmdletBinding()]
param(
  [switch]$Execute,
  [string[]]$Departments = @("HR","Finance","Engineering","Sales"),
  [string]$DomainNetBIOS = "robslab"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

function Write-Plan {
  param([string]$Message)
  Write-Host "[PLAN] $Message"
}

function Write-Do {
  param([string]$Message)
  if ($Execute) { Write-Host "[DO]   $Message" } else { Write-Host "[DRY]  $Message" }
}

function Ensure-Group {
  param(
    [Parameter(Mandatory)] [string]$GroupName,
    [ValidateSet("Global","DomainLocal","Universal")] [string]$Scope = "Global",
    [ValidateSet("Security","Distribution")] [string]$Type = "Security"
  )

  $g = Get-ADGroup -Identity $GroupName -ErrorAction SilentlyContinue
  if (-not $g) {
    Write-Do "Create group: $GroupName ($Scope, $Type)"
    if ($Execute) {
      New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupScope $Scope -GroupCategory $Type | Out-Null
    }
  } else {
    Write-Plan "Group exists: $GroupName"
  }
}

function Remove-MemberIfPresent {
  param(
    [Parameter(Mandatory)] [string]$ParentGroup,
    [Parameter(Mandatory)] [string]$MemberGroup
  )

  $members = Get-ADGroupMember -Identity $ParentGroup -Recursive:$false | Select-Object -ExpandProperty SamAccountName
  if ($members -contains $MemberGroup) {
    Write-Do "Remove $MemberGroup from $ParentGroup"
    if ($Execute) {
      Remove-ADGroupMember -Identity $ParentGroup -Members $MemberGroup -Confirm:$false
    }
  } else {
    Write-Plan "$MemberGroup not a direct member of $ParentGroup"
  }
}

function Add-MemberIfMissing {
  param(
    [Parameter(Mandatory)] [string]$ParentGroup,
    [Parameter(Mandatory)] [string]$MemberGroup
  )

  $members = Get-ADGroupMember -Identity $ParentGroup -Recursive:$false | Select-Object -ExpandProperty SamAccountName
  if ($members -contains $MemberGroup) {
    Write-Plan "$MemberGroup already a direct member of $ParentGroup"
  } else {
    Write-Do "Add $MemberGroup to $ParentGroup"
    if ($Execute) {
      Add-ADGroupMember -Identity $ParentGroup -Members $MemberGroup
    }
  }
}

# Sanity check: required DL groups exist
function Assert-GroupExists {
  param([string]$GroupName)
  if (-not (Get-ADGroup -Identity $GroupName -ErrorAction SilentlyContinue)) {
    throw "Required group not found: $GroupName. Create it first or fix the name."
  }
}

Write-Host ""
Write-Host "=== RBAC File Share Group Fix ==="
Write-Host "Mode: " -NoNewline
if ($Execute) { Write-Host "EXECUTE (changes will be made)" } else { Write-Host "DRY-RUN (no changes)" }
Write-Host ""

# Departments: remove GG_<Dept>_Users from both DL_FS_<Dept>_(RO|RW),
# create GG_<Dept>_(Staff|Lead), nest into DLs.
foreach ($dept in $Departments) {
  $dept = $dept.Trim()

  $ggUsers  = "GG_${dept}_Users"
  $ggStaff  = "GG_${dept}_Staff"
  $ggLead   = "GG_${dept}_Lead"
  $dlRO     = "DL_FS_${dept}_RO"
  $dlRW     = "DL_FS_${dept}_RW"

  Write-Host ""
  Write-Host "--- Department: $dept ---"

  # Validate DL groups exist (these should already exist in your model)
  Assert-GroupExists $dlRO
  Assert-GroupExists $dlRW

  # If the dept membership group exists, remove it from both permission DLs
  if (Get-ADGroup -Identity $ggUsers -ErrorAction SilentlyContinue) {
    Remove-MemberIfPresent -ParentGroup $dlRO -MemberGroup $ggUsers
    Remove-MemberIfPresent -ParentGroup $dlRW -MemberGroup $ggUsers
  } else {
    Write-Plan "Dept membership group missing (skipping removal): $ggUsers"
  }

  # Ensure role groups exist
  Ensure-Group -GroupName $ggStaff -Scope Global -Type Security
  Ensure-Group -GroupName $ggLead  -Scope Global -Type Security

  # Nest role groups into DL permission groups
  Add-MemberIfMissing -ParentGroup $dlRO -MemberGroup $ggStaff
  Add-MemberIfMissing -ParentGroup $dlRW -MemberGroup $ggLead
}

# IT mapping (uses existing role groups)
Write-Host ""
Write-Host "--- IT Mapping ---"
$itHelpdesk = "GG_IT_Helpdesk"
$itSrvAdmins = "GG_IT_ServerAdmins"
$itDlRO = "DL_FS_IT_RO"
$itDlRW = "DL_FS_IT_RW"

Assert-GroupExists $itDlRO
Assert-GroupExists $itDlRW

if (-not (Get-ADGroup -Identity $itHelpdesk -ErrorAction SilentlyContinue)) {
  throw "Required IT role group not found: $itHelpdesk"
}
if (-not (Get-ADGroup -Identity $itSrvAdmins -ErrorAction SilentlyContinue)) {
  throw "Required IT role group not found: $itSrvAdmins"
}

Add-MemberIfMissing -ParentGroup $itDlRO -MemberGroup $itHelpdesk
Add-MemberIfMissing -ParentGroup $itDlRW -MemberGroup $itSrvAdmins

Write-Host ""
Write-Host "=== Done ==="
Write-Host "If this was a dry-run, re-run with -Execute to apply changes."