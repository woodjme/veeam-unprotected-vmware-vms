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
	if ($protectedvms.Contains($vm)) {
		Write-Host -ForegroundColor Green "Backup found for $vm"
	} else {
		Write-Host -ForegroundColor Red "No Backup found for $vm"
	}
}
