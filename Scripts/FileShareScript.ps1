<#
IAM + File Share group bootstrap for robslab.local

What it does:
1) Creates missing groups:
   - DL_FS_<Dept>_RW
   - DL_FS_<Dept>_RO
   - GG_<Dept>_Users
   - DL_FS_Admins (optional if missing)

2) Nests:
   GG_<Dept>_Users -> DL_FS_<Dept>_RW (default)
   (RO nesting optional)

3) Adds users to GG groups based on OU:
   OU=<Dept>,OU=Users,OU=Corp,DC=robslab,DC=local

Adjust the base DNs below to match your exact OU structure.
#>

Import-Module ActiveDirectory

# ====== EDIT THESE TO MATCH YOUR DOMAIN/OUs ======
$DomainDN      = (Get-ADDomain).DistinguishedName
$GroupsOU      = "OU=Groups,OU=Corp,$DomainDN"
$UsersBaseOU   = "OU=Users,OU=Corp,$DomainDN"     # assumes dept OUs live under this
$Depts         = @("Engineering","Finance","HR","IT","Sales")

# Optional: who should be file share admins
$FileShareAdmins = @("robert.garcia-adm")          # change or leave empty @()

# Default behavior: everyone in a dept OU gets RW. If you want RO-only users, handle separately later.
$NestRW = $true
$NestRO = $false

# ====== HELPERS ======
function Ensure-ADGroup {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Path,
        [string] $Description = ""
    )
    $g = Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue
    if (-not $g) {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope Global -GroupCategory Security -Path $Path -Description $Description
        Write-Host "Created group: $Name"
    } else {
        Write-Host "Exists: $Name"
    }
}

function Ensure-GroupMember {
    param(
        [Parameter(Mandatory)] [string] $Group,
        [Parameter(Mandatory)] [string] $Member
    )
    try {
        $already = Get-ADGroupMember -Identity $Group -Recursive | Where-Object { $_.SamAccountName -eq $Member }
        if (-not $already) {
            Add-ADGroupMember -Identity $Group -Members $Member
            Write-Host "Added $Member -> $Group"
        } else {
            Write-Host "Already member: $Member -> $Group"
        }
    } catch {
        Write-Host "WARN: Could not add $Member -> $Group. $_"
    }
}

# ====== CORE GROUPS ======
Ensure-ADGroup -Name "DL_FS_Admins" -Path $GroupsOU -Description "File server admins"

foreach ($dept in $Depts) {
    $gg = "GG_${dept}_Users"
    $dlrw = "DL_FS_${dept}_RW"
    $dlro = "DL_FS_${dept}_RO"

    Ensure-ADGroup -Name $gg   -Path $GroupsOU -Description "$dept department users"
    Ensure-ADGroup -Name $dlrw -Path $GroupsOU -Description "RW access to $dept file share"
    Ensure-ADGroup -Name $dlro -Path $GroupsOU -Description "RO access to $dept file share"

    if ($NestRW) { Ensure-GroupMember -Group $dlrw -Member $gg }
    if ($NestRO) { Ensure-GroupMember -Group $dlro -Member $gg }
}

# ====== ADD USERS TO THE RIGHT GG BASED ON THEIR OU ======
foreach ($dept in $Depts) {
    $deptOU = "OU=$dept,$UsersBaseOU"
    $gg = "GG_${dept}_Users"

    # Pull enabled user accounts from the dept OU
    $users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $deptOU -SearchScope Subtree -Properties SamAccountName |
             Select-Object -ExpandProperty SamAccountName

    foreach ($u in $users) {
        Ensure-GroupMember -Group $gg -Member $u
    }
}

# ====== OPTIONAL: ADD FILE SHARE ADMINS ======
foreach ($a in $FileShareAdmins) {
    Ensure-GroupMember -Group "DL_FS_Admins" -Member $a
}

Write-Host "Done."