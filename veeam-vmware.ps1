###
# Produce a list of unprotected virtual machines
##

Add-PSSnapin VeeamPSSnapin
Import-Module VMware.PowerCLI

###
# Configuration
##
$vcenters = @("0.0.0.0", "0.0.0.0")
$veeamServers = @("0.0.0.0", "0.0.0.0")
$credential = Get-Credential

# Get virtual machines from VMWare
Connect-VIServer -Server $vcenters -Credential $credential
$virtualmachines = @()
foreach ($vm in (Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"})) {
	$virtualmachines += $vm.Name
}

# Get a list of virtual machines that do not require a backup
$excludedMachines = @()
foreach ($vm in (Get-VM -Tag "Backup Not Required" | Where-Object {$_.PowerState -eq "PoweredOn"})) {
	$excludedMachines += $vm.name
}

# Get a list of protected virtual machines from Veeam
Disconnect-VBRServer
$protectedvms = @()
foreach ($veeamServer in $veeamServers) {
	Connect-VBRServer -Server $veeamServer
	foreach ($protectedvm in (Get-VBRRestorePoint | Select-Object VmName -Unique)) {
		$protectedvms += $protectedvm.VmName
	}
	Disconnect-VBRServer
}

# Print List
foreach ($vm in $virtualmachines) {
	if ($protectedvms.Contains($vm) -And $excludedMachines.Contains($vm)) {
		Write-Host -ForegroundColor Yellow "$vm - is protected, but should be excluded"
	} elseif ( -Not $protectedvms.Contains($vm) -And $excludedMachines.Contains($vm)){
		Write-Host -ForegroundColor DarkGreen "$vm - is not protected and shouldn't be"
	} elseif (-Not $protectedvms.Contains($vm)) {
		Write-Host  -ForegroundColor Red "$vm - is not backed up and should be"
	} else {
		Write-Host -ForegroundColor Green "$vm - is backed up and should be"
	}
}
