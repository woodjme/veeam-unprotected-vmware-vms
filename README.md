# veeam-unprotected-vmware-vms

## Configuration

Define your VMWare/vCenter and Veeam hosts in the config section

```powershell
$vcenters = @("0.0.0.0", "0.0.0.0")
$veeamServers = @("0.0.0.0", "0.0.0.0")
```

## Run

### Parameters

```powershell
Param(
  [Boolean]$showProtected, # Hide protected VM's. OPTIONAL.
  [String]$noBackupTag # The name of the tag used in VMware to declare that the VM does not been to be protected. OPTIONAL.
)
```

```powershell
 .\vmware.ps1 -showProtected $true -noBackupTag "Backup Not Required"
```
