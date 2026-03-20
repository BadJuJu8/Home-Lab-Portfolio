<#
.SYNOPSIS
    Mover.ps1 - Moves AD users to a new department/role with group and OU updates.

.DESCRIPTION
    Reads a CSV of users to move. For each user: captures before state, removes old
    identity groups, adds new identity groups, updates Department/Title attributes,
    moves the account to the correct OU, and produces a per-run report CSV.

    Default mode is DRY RUN. Pass -Execute to commit changes.

.PARAMETER CsvPath
    Path to the input CSV. Required columns: SamAccountName, NewDepartment, NewRole, NewTitle

.PARAMETER LogPath
    Path to the log file (appended).

.PARAMETER ReportPath
    Path for the per-run evidence CSV (new file each run, timestamped if omitted).

.PARAMETER Execute
    Switch. When present, changes are committed to AD.

.EXAMPLE
    # Dry run:
    .\Mover.ps1 -CsvPath C:\LabArtifacts\JML\mover.csv -LogPath C:\Logs\mover.log

.EXAMPLE
    # Live run:
    .\Mover.ps1 -CsvPath C:\LabArtifacts\JML\mover.csv -LogPath C:\Logs\mover.log -Execute
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [Parameter(Mandatory)]
    [string]$LogPath,

    [string]$ReportPath,

    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────

$DeptMap = @{
    "Sales"       = @{ UserOU = "OU=Sales,OU=Users,OU=Corp,DC=robslab,DC=local" }
    "IT"          = @{ UserOU = "OU=IT,OU=Users,OU=Corp,DC=robslab,DC=local" }
    "HR"          = @{ UserOU = "OU=HR,OU=Users,OU=Corp,DC=robslab,DC=local" }
    "Finance"     = @{ UserOU = "OU=Finance,OU=Users,OU=Corp,DC=robslab,DC=local" }
    "Engineering" = @{ UserOU = "OU=Engineering,OU=Users,OU=Corp,DC=robslab,DC=local" }
}

$AllowedRoles      = @("Users", "Staff", "Lead")
$ExemptGroups      = @("Domain Users")
$IdentityGroupPattern = '^GG_[^_]+_(Users|Staff|Lead)$'

# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","DRYRUN")]
        [string]$Level = "INFO"
    )
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts [$Level] $Message"
    $line | Out-File -FilePath $LogPath -Append -Encoding utf8
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

function Get-IdentityGroups {
    # Returns only GG_<Dept>_(Users|Staff|Lead) groups from a list of group names
    param([string[]]$GroupNames)
    return $GroupNames | Where-Object { $_ -match $IdentityGroupPattern }
}

function Get-TargetGroups {
    # Computes the target identity group set for a dept+role combo
    param([string]$Dept, [string]$Role)
    $groups = [System.Collections.Generic.List[string]]::new()
    $groups.Add("GG_${Dept}_Users")          # always assigned
    if ($Role -eq "Staff") { $groups.Add("GG_${Dept}_Staff") }
    if ($Role -eq "Lead")  { $groups.Add("GG_${Dept}_Lead") }
    return $groups
}

function Get-OUFromDN {
    param([string]$DN)
    # Strips the CN=... component to return the parent OU path
    return ($DN -replace '^CN=[^,]+,', '')
}

# ─────────────────────────────────────────────
# REPORT SETUP
# ─────────────────────────────────────────────

if (-not $ReportPath) {
    $stamp      = Get-Date -Format "yyyyMMdd_HHmmss"
    $ReportPath = "C:\Logs\mover_report_$stamp.csv"
}

$reportRows = [System.Collections.Generic.List[hashtable]]::new()

function Add-ReportRow {
    param(
        [string]$Timestamp, [string]$Action, [string]$SamAccountName,
        [string]$DisplayName, [string]$OldOU, [string]$NewOU,
        [string]$OldGroups, [string]$NewGroups,
        [string]$AddedGroups, [string]$RemovedGroups,
        [string]$Status, [string]$Error
    )
    $reportRows.Add(@{
        Timestamp      = $Timestamp
        Action         = $Action
        SamAccountName = $SamAccountName
        DisplayName    = $DisplayName
        OldOU          = $OldOU
        NewOU          = $NewOU
        OldGroups      = $OldGroups
        NewGroups      = $NewGroups
        AddedGroups    = $AddedGroups
        RemovedGroups  = $RemovedGroups
        Status         = $Status
        Error          = $Error
    })
}

# ─────────────────────────────────────────────
# PREFLIGHT
# ─────────────────────────────────────────────

Import-Module ActiveDirectory

$mode = if ($Execute) { "LIVE" } else { "DRY RUN" }
Write-Log "=== Mover.ps1 start | Mode=$mode | CsvPath=$CsvPath ==="

if (-not $Execute) {
    Write-Log "DRY RUN MODE — no AD changes will be made. Re-run with -Execute to commit." -Level "DRYRUN"
}

if (-not (Test-Path -Path $CsvPath)) { Stop-Run "CSV not found: $CsvPath" }

$rows = @(Import-Csv -Path $CsvPath)
if ($rows.Length -eq 0) { Stop-Run "CSV has no rows: $CsvPath" }

Write-Log "Loaded $($rows.Length) row(s) from CSV."

# ─────────────────────────────────────────────
# VALIDATE ALL ROWS
# ─────────────────────────────────────────────

Write-Log "--- Validating all rows ---"

$validated = [System.Collections.Generic.List[hashtable]]::new()

foreach ($r in $rows) {
    $Sam       = Normalize-Key $r.SamAccountName
    $NewDept   = Normalize-Key $r.NewDepartment
    $NewRole   = Normalize-Key $r.NewRole
    $NewTitle  = Normalize-Key $r.NewTitle

    if ([string]::IsNullOrWhiteSpace($Sam)) {
        Stop-Run "Row missing SamAccountName. Row=$($r | ConvertTo-Json -Compress)"
    }
    if (-not $DeptMap.ContainsKey($NewDept)) {
        Stop-Run "Invalid NewDepartment '$NewDept' for Sam='$Sam'. Allowed: $($DeptMap.Keys -join ', ')"
    }
    if ($NewRole -notin $AllowedRoles) {
        Stop-Run "Invalid NewRole '$NewRole' for Sam='$Sam'. Allowed: $($AllowedRoles -join ', ')"
    }

    $validated.Add(@{
        Sam      = $Sam
        NewDept  = $NewDept
        NewRole  = $NewRole
        NewTitle = $NewTitle
    })
}

Write-Log "All $($validated.Count) row(s) passed CSV validation."

# ─────────────────────────────────────────────
# PRE-VALIDATE AD OBJECTS
# ─────────────────────────────────────────────

Write-Log "--- Checking AD OUs and Groups exist ---"

$combosNeeded = $validated | ForEach-Object { "$($_["NewDept"])|$($_["NewRole"])" } | Select-Object -Unique
foreach ($combo in $combosNeeded) {
    $dept, $role = $combo -split '\|'

    $ou = $DeptMap[$dept].UserOU
    try { Get-ADOrganizationalUnit -Identity $ou | Out-Null }
    catch { Stop-Run "Target OU does not exist: $ou" }

    foreach ($g in (Get-TargetGroups -Dept $dept -Role $role)) {
        try { Get-ADGroup -Identity $g | Out-Null }
        catch { Stop-Run "Required identity group missing: $g" }
    }
}

Write-Log "All required OUs and Groups confirmed present."

# ─────────────────────────────────────────────
# PROCESS USERS
# ─────────────────────────────────────────────

Write-Log "--- Processing users ---"

$processed = 0
$changed   = 0
$skipped   = 0
$failed    = 0

foreach ($u in $validated) {
    $Sam      = $u["Sam"]
    $NewDept  = $u["NewDept"]
    $NewRole  = $u["NewRole"]
    $NewTitle = $u["NewTitle"]
    $ts       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try {
        $processed++

        # Resolve user
        $adUser = Get-ADUser -Identity $Sam -Properties MemberOf, Department, Title, DistinguishedName `
                             -ErrorAction SilentlyContinue
        if (-not $adUser) {
            Write-Log "FAILED Sam='$Sam' — user not found in AD." -Level "ERROR"
            Add-ReportRow -Timestamp $ts -Action "MOVE" -SamAccountName $Sam `
                -Status "FAILED" -Error "User not found in AD"
            $failed++
            continue
        }

        $displayName = $adUser.Name

        # ── BEFORE STATE ──
        $oldDN     = $adUser.DistinguishedName
        $oldOU     = Get-OUFromDN $oldDN
        $allGroups = $adUser.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }
        $oldIdentityGroups = @(Get-IdentityGroups -GroupNames $allGroups)

        # ── TARGET ──
        $targetOU     = $DeptMap[$NewDept].UserOU
        $targetGroups = @(Get-TargetGroups -Dept $NewDept -Role $NewRole)

        $toRemove = @($oldIdentityGroups | Where-Object { $_ -notin $targetGroups })
        $toAdd    = @($targetGroups | Where-Object { $_ -notin $oldIdentityGroups })

        $ouAlreadyCorrect    = ($oldOU -eq $targetOU)
        $deptAlreadyCorrect  = ($adUser.Department -eq $NewDept)
        $titleAlreadyCorrect = ($adUser.Title -eq $NewTitle)
        $groupsAlreadyCorrect = ($toAdd.Count -eq 0 -and $toRemove.Count -eq 0)

        # ── IDEMPOTENCY CHECK ──
        if ($ouAlreadyCorrect -and $deptAlreadyCorrect -and $titleAlreadyCorrect -and $groupsAlreadyCorrect) {
            Write-Log "SKIP Sam='$Sam' — already in correct state." -Level "WARN"
            Add-ReportRow -Timestamp $ts -Action "MOVE" -SamAccountName $Sam `
                -DisplayName $displayName -OldOU $oldOU -NewOU $targetOU `
                -OldGroups ($oldIdentityGroups -join ';') -NewGroups ($targetGroups -join ';') `
                -AddedGroups "" -RemovedGroups "" -Status "SKIPPED" -Error ""
            $skipped++
            continue
        }

        # ── LOG PLANNED ACTIONS ──
        Write-Log "MOVE Sam='$Sam' OldOU='$oldOU' -> NewOU='$targetOU'"
        Write-Log "     Dept: '$($adUser.Department)' -> '$NewDept' | Title: '$($adUser.Title)' -> '$NewTitle'"
        if ($toRemove.Count -gt 0) { Write-Log "     REMOVE groups: $($toRemove -join ', ')" }
        if ($toAdd.Count -gt 0)    { Write-Log "     ADD groups:    $($toAdd -join ', ')" }

        if ($Execute) {
            # 1. Remove old identity groups
            foreach ($g in $toRemove) {
                Remove-ADGroupMember -Identity $g -Members $Sam -Confirm:$false
                Write-Log "     Removed from '$g'"
            }

            # 2. Add new identity groups
            foreach ($g in $toAdd) {
                Add-ADGroupMember -Identity $g -Members $Sam
                Write-Log "     Added to '$g'"
            }

            # 3. Update attributes
            Set-ADUser -Identity $Sam -Department $NewDept -Title $NewTitle

            # 4. Move OU if needed
            if (-not $ouAlreadyCorrect) {
                Move-ADObject -Identity $oldDN -TargetPath $targetOU
                Write-Log "     Moved to OU '$targetOU'"
            }

            # ── AFTER STATE ──
            $afterUser   = Get-ADUser -Identity $Sam -Properties MemberOf, DistinguishedName
            $afterGroups = $afterUser.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }
            $afterIdentityGroups = @(Get-IdentityGroups -GroupNames $afterGroups)
            $afterOU     = Get-OUFromDN $afterUser.DistinguishedName

            Write-Log "DONE Sam='$Sam' NewOU='$afterOU' Groups='$($afterIdentityGroups -join ';')'"

            Add-ReportRow -Timestamp $ts -Action "MOVE" -SamAccountName $Sam `
                -DisplayName $displayName -OldOU $oldOU -NewOU $afterOU `
                -OldGroups ($oldIdentityGroups -join ';') -NewGroups ($afterIdentityGroups -join ';') `
                -AddedGroups ($toAdd -join ';') -RemovedGroups ($toRemove -join ';') `
                -Status "CHANGED" -Error ""

        } else {
            Write-Log "DRYRUN Sam='$Sam' — no changes made." -Level "DRYRUN"

            Add-ReportRow -Timestamp $ts -Action "MOVE" -SamAccountName $Sam `
                -DisplayName $displayName -OldOU $oldOU -NewOU $targetOU `
                -OldGroups ($oldIdentityGroups -join ';') -NewGroups ($targetGroups -join ';') `
                -AddedGroups ($toAdd -join ';') -RemovedGroups ($toRemove -join ';') `
                -Status "DRYRUN" -Error "" `
        }

        $changed++

    } catch {
        Write-Log "FAILED Sam='$Sam': $_" -Level "ERROR"
        Add-ReportRow -Timestamp $ts -Action "MOVE" -SamAccountName $Sam `
            -Status "FAILED" -Error "$_"
        $failed++
    }
}

# ─────────────────────────────────────────────
# WRITE REPORT CSV
# ─────────────────────────────────────────────

if ($reportRows.Count -gt 0) {
    $reportRows | ForEach-Object {
        [PSCustomObject]$_
    } | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding utf8
    Write-Log "Report written to $ReportPath"
}

# ─────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────

Write-Log "--- Summary | Mode=$mode | Processed=$processed | Changed=$changed | Skipped=$skipped | Failed=$failed ---"
Write-Log "=== Mover.ps1 end ==="

