<#
.SYNOPSIS
    Joiner.ps1 - Creates AD users from a CSV with strict validation, group assignment, and logging.

.DESCRIPTION
    Reads a CSV of new starters and creates AD user accounts. Validates Department and Role
    against allow-lists, assigns department and role groups, and logs all actions.

    By default runs in DRY RUN mode — no changes are made to AD.
    Pass -Execute to actually create users and assign groups.

.PARAMETER CsvPath
    Path to the input CSV file. Required columns: FirstName, LastName, Department, Role, Title

.PARAMETER LogPath
    Path to the output log file. Will be created/appended.

.PARAMETER Execute
    Switch. When present, changes are committed to AD. Without it, the script is a dry run.

.EXAMPLE
    # Dry run (safe, no changes):
    .\Joiner.ps1 -CsvPath C:\LabArtifacts\JML\joiner.csv -LogPath C:\Logs\joiner.log

.EXAMPLE
    # Live run (actually creates users):
    .\Joiner.ps1 -CsvPath C:\LabArtifacts\JML\joiner.csv -LogPath C:\Logs\joiner.log -Execute
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [Parameter(Mandatory)]
    [string]$LogPath,

    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─────────────────────────────────────────────
# CONFIGURATION — edit these to match your environment
# ─────────────────────────────────────────────

$DeptMap = @{
    "Sales"       = @{ UserOU = "OU=Sales,OU=Users,OU=Corp,DC=robslab,DC=local";       DeptGroup = "GG_Sales_Users" }
    "IT"          = @{ UserOU = "OU=IT,OU=Users,OU=Corp,DC=robslab,DC=local";          DeptGroup = "GG_IT_Users" }
    "HR"          = @{ UserOU = "OU=HR,OU=Users,OU=Corp,DC=robslab,DC=local";          DeptGroup = "GG_HR_Users" }
    "Finance"     = @{ UserOU = "OU=Finance,OU=Users,OU=Corp,DC=robslab,DC=local";     DeptGroup = "GG_Finance_Users" }
    "Engineering" = @{ UserOU = "OU=Engineering,OU=Users,OU=Corp,DC=robslab,DC=local"; DeptGroup = "GG_Engineering_Users" }
}

$AllowedRoles=("Users","Staff","Lead","Manager","Executive")

$Domain         = "robslab.local"
$TempPassword   = "P@ssw0rd!ChangeMe"

# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","DRYRUN")]
        [string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts [$Level] $Message"
    "$line" | Out-File -FilePath $LogPath -Append -Encoding utf8
    # Also write to console with colour
    switch ($Level) {
        "ERROR"  { Write-Host $line -ForegroundColor Red }
        "WARN"   { Write-Host $line -ForegroundColor Yellow }
        "DRYRUN" { Write-Host $line -ForegroundColor Cyan }
        default  { Write-Host $line -ForegroundColor Green }
    }
}

function Stop-Run {
    param([string]$Message)
    Write-Log -Message $Message -Level "ERROR"
    throw $Message
}

# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

function Normalize-Key {
    param([string]$s)
    if ([string]::IsNullOrWhiteSpace($s)) { return "" }
    return $s.Trim()
}

function New-SamAccountName {
    param(
        [string]$FirstName,
        [string]$LastName
    )
    $base = (($FirstName.Substring(0,1) + $LastName) -replace "[^a-zA-Z0-9]", "").ToLower()
    if ($base.Length -gt 20) { $base = $base.Substring(0,20) }

    $sam = $base
    $i = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        $suffix = $i.ToString()
        $maxBase = 20 - $suffix.Length
        $trimmed = if ($base.Length -gt $maxBase) { $base.Substring(0,$maxBase) } else { $base }
        $sam = "$trimmed$suffix"
        $i++
        if ($i -gt 99) { Stop-Run "Cannot generate unique SamAccountName for $FirstName $LastName after 99 attempts." }
    }
    return $sam
}

# ─────────────────────────────────────────────
# PREFLIGHT
# ─────────────────────────────────────────────

Import-Module ActiveDirectory

$mode = if ($Execute) { "LIVE" } else { "DRY RUN" }
Write-Log "=== Joiner.ps1 start | Mode=$mode | CsvPath=$CsvPath ==="

if (-not $Execute) {Write-Log "DRY RUN MODE — no AD changes will be made. Re-run with -Execute to commit." -Level "DRYRUN"}

if (-not (Test-Path -Path $CsvPath)) { Stop-Run "CSV not found: $CsvPath" }

$rows = @(Import-Csv -Path $CsvPath)
if ($rows.Length -eq 0) { Stop-Run "CSV has no rows: $CsvPath" }

Write-Log "Loaded $($rows.Length) row(s) from CSV."

# ─────────────────────────────────────────────
# VALIDATE ALL ROWS BEFORE TOUCHING AD
# (fail fast — catch all CSV problems up front)
# ─────────────────────────────────────────────

Write-Log "--- Validating all rows ---"

$validated = [System.Collections.Generic.List[hashtable]]::new()

foreach ($r in $rows) {
    $FirstName  = Normalize-Key $r.FirstName
    $LastName   = Normalize-Key $r.LastName
    $Department = Normalize-Key $r.Department
    $Role       = Normalize-Key $r.Role
    $Title      = Normalize-Key $r.Title

    # Required fields
    if ([string]::IsNullOrWhiteSpace($FirstName) -or [string]::IsNullOrWhiteSpace($LastName)) {
        Stop-Run "Row missing FirstName or LastName. Row=$($r | ConvertTo-Json -Compress)"
    }

    # Department allow-list
    if (-not $DeptMap.ContainsKey($Department)) {
        Stop-Run "Invalid Department '$Department' for $FirstName $LastName. Allowed: $($DeptMap.Keys -join ', ')"
    }

    # Role allow-list
    if ($Role -notin $AllowedRoles) {
        Stop-Run "Invalid Role '$Role' for $FirstName $LastName. Allowed: $($AllowedRoles -join ', ')"
    }

    $validated.Add(@{
        FirstName  = $FirstName
        LastName   = $LastName
        Department = $Department
        Role       = $Role
        Title      = $Title
    })
}

Write-Log "All $($validated.Count) row(s) passed validation."

# ─────────────────────────────────────────────
# PRE-VALIDATE AD OBJECTS (OUs & Groups exist)
# ─────────────────────────────────────────────

Write-Log "--- Checking AD OUs and Groups exist ---"

$deptsNeeded = $validated | ForEach-Object { $_["Department"] } | Select-Object -Unique
foreach ($dept in $deptsNeeded) {
    $ou = $DeptMap[$dept].UserOU
    $dg = $DeptMap[$Department].DeptGroup
    try { Get-ADOrganizationalUnit -Identity $ou | Out-Null }
    catch { Stop-Run "Target OU does not exist: $ou" }
    try { Get-ADGroup -Identity $dg | Out-Null }
    catch { Stop-Run "Required dept group missing: $dg" }
}

$combosNeeded = $validated | ForEach-Object { "$($_['Department'])|$($_['Role'])"} | Select-Object -Unique
foreach ($combo in $combosNeeded) {
    $dept, $role = $combo -split '\|'
    $rg = "GG_${dept}_${role}"
    try { Get-ADGroup -Identity $rg | Out-Null }
    catch { Stop-Run "Required role group missing: $rg" }
}

Write-Log "All required OUs and Groups confirmed present."

# ─────────────────────────────────────────────
# PROCESS USERS
# ─────────────────────────────────────────────

Write-Log "--- Processing users ---"

$created = 0
$skipped = 0
$failed  = 0

foreach ($u in $validated) {
    $FirstName  = $u["FirstName"]
    $LastName   = $u["LastName"]
    $Department = $u["Department"]
    $Role       = $u["Role"]
    $Title      = $u["Title"]

    $userOU     = $DeptMap[$Department].UserOU
    $deptGroup  = $DeptMap[$Department].DeptGroup
    $roleGroup  = "GG_${dept}_${role}"
    $displayName = "$FirstName $LastName"

    try {
        # ── IDEMPOTENCY: check if user already exists by display name or a
        #    predictable UPN. We derive the base SAM to check UPN first.
        $baseSam = (($FirstName.Substring(0,1) + $LastName) -replace "[^a-zA-Z0-9]","").ToLower()
        if ($baseSam.Length -gt 20) { $baseSam = $baseSam.Substring(0,20) }
        $baseUpn = "$baseSam@$Domain"

        $existingUser = Get-ADUser -Filter "UserPrincipalName -eq '$baseUpn'" `
                                   -Properties MemberOf, Department, Title `
                                   -ErrorAction SilentlyContinue

        if ($existingUser) {
            # User already exists — check groups and patch if needed
            Write-Log "SKIP (already exists) UPN='$baseUpn' Sam='$($existingUser.SamAccountName)'" -Level "WARN"

            $currentGroups = $existingUser.MemberOf |
                ForEach-Object { (Get-ADGroup $_).Name }

            foreach ($g in @($deptGroup, $roleGroup)) {
                if ($currentGroups -notcontains $g) {
                    if ($Execute) {
                        Add-ADGroupMember -Identity $g -Members $existingUser.SamAccountName
                        Write-Log "REMEDIATE added missing group '$g' to Sam='$($existingUser.SamAccountName)'"
                    } else {
                        Write-Log "DRYRUN would add missing group '$g' to Sam='$($existingUser.SamAccountName)'" -Level "DRYRUN"
                    }
                }
            }
            $skipped++
            continue
        }

        # ── NEW USER ──
        $sam = New-SamAccountName -FirstName $FirstName -LastName $LastName
        $upn = "$sam@$Domain"
        $securePw = ConvertTo-SecureString $TempPassword -AsPlainText -Force

        if ($Execute) {
            New-ADUser `
                -Name            $displayName `
                -GivenName       $FirstName `
                -Surname         $LastName `
                -DisplayName     $displayName `
                -SamAccountName  $sam `
                -UserPrincipalName $upn `
                -Title           $Title `
                -Department      $Department `
                -Path            $userOU `
                -AccountPassword $securePw `
                -Enabled         $true `
                -ChangePasswordAtLogon $true

            Add-ADGroupMember -Identity $deptGroup -Members $sam
            Add-ADGroupMember -Identity $roleGroup -Members $sam

            # Evidence snapshot
            $memberOf = (Get-ADUser -Identity $sam -Properties MemberOf).MemberOf |
                ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

            Write-Log "CREATED Name='$displayName' Sam='$sam' UPN='$upn' Dept='$Department' Role='$Role' OU='$userOU'"
            Write-Log "GROUPS  Sam='$sam' Groups='$($memberOf -join ';')' TempPw=SET ChangeAtLogon=True"
        } else {
            Write-Log "DRYRUN would CREATE Name='$displayName' Sam='$sam' UPN='$upn' Dept='$Department' Role='$Role' OU='$userOU'" -Level "DRYRUN"
            Write-Log "DRYRUN would ADD groups '$deptGroup' and '$roleGroup' to Sam='$sam'" -Level "DRYRUN"
        }

        $created++

    } catch {
        Write-Log "FAILED for '$displayName': $_" -Level "ERROR"
        $failed++
    }
}

# ─────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────

Write-Log "--- Summary | Mode=$mode | Created=$created | Skipped(existing)=$skipped | Failed=$failed ---"
Write-Log "=== Joiner.ps1 end ==="







