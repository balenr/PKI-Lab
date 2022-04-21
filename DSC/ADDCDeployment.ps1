#
# Windows PowerShell script for AD DS Deployment
#

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "F:\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "whsec.lab" `
-DomainNetbiosName "WHSEC" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "F:\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "F:\SYSVOL" `
-Force:$true
