###
# Produce a list of unprotected virtual machines
##

###
# Parameters
##
Param(
  [Boolean]$showProtected = $False,
  $noBackupTag
)

Add-PSSnapin VeeamPSSnapin
Import-Module VMware.PowerCLI

###
# Configuration
##
$vcenters = @("0.0.0.0", "0.0.0.0")
$veeamServers = @("0.0.0.0", "0.0.0.0")
$credential = Get-Credential


$virtualMachines = @()
$protectedVMs = @()
$excludedMachines = @()

# Get virtual machines from VMWare
Connect-VIServer -Server $vcenters -Credential $credential
foreach ($vm in (Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"})) {
	$virtualMachines += $vm.Name
}

# Get a list of virtual machines that do not require a backup
if($noBackupTag) {
	foreach ($vm in (Get-VM -Tag $noBackupTag)) {
		$excludedMachines += $vm.name
	}
}

# Get a list of protected virtual machines from Veeam
Disconnect-VBRServer
foreach ($veeamServer in $veeamServers) {
	Connect-VBRServer -Server $veeamServer
	foreach ($protectedvm in (Get-VBRRestorePoint | Select-Object VmName -Unique)) {
		$protectedVMs += $protectedvm.VmName
	}
	Disconnect-VBRServer
}

# Print List
foreach ($vm in $virtualMachines) {
	if ($protectedVMs.Contains($vm) -And $excludedMachines.Contains($vm)) {
		Write-Host -ForegroundColor Yellow "$vm - is protected, but should be excluded"
	} elseif ( -Not $protectedVMs.Contains($vm) -And $excludedMachines.Contains($vm)){
		Write-Host -ForegroundColor DarkGreen "$vm - is not protected and shouldn't be"
	} elseif (-Not $protectedVMs.Contains($vm)) {
		Write-Host  -ForegroundColor Red "$vm - is not protected"
	} elseif ($showProtected) {
		Write-Host -ForegroundColor Green "$vm - is protected"
	}
}
