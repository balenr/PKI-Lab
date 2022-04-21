Configuration TestConfig {

    Param (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [PSCredential]$AdminCreds,

        [Int]$RetryCount = 20,
        [Int]$RetryInterval = 30
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'StorageDsc'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    $Interface = Get-NetAdapter | Where-Object { $_.Name -like "Ethernet" } | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node 'localhost' {
        LocalConfigurationManager {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature 'RSAT' {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        WaitForDisk 'Disk2' {
            DiskId           = 2
            RetryIntervalSec = $RetryInterval
            RetryCount       = $RetryCount
        }

        Disk 'ADDataDisk' {
            DiskId      = 2
            DriveLetter = "F"
            DependsOn   = "[WaitForDisk]Disk2"
        }

        WindowsFeature 'DNS' {
            Name   = 'DNS'
            Ensure = 'Present'
        }

        WindowsFeature 'DNSTools' {
            Name      = 'RSAT-DNS-Server'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]DNS'
        }

        DnsServerAddress 'DnsServerAddress' {
            Address        = '127.0.0.1'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn      = '[WindowsFeature]DNS'
        }

        WindowsFeature 'ADDS' {
            Name      = 'AD-Domain-Services'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]DNS'
        }

        WindowsFeature 'ADDSTools' {
            Name      = 'RSAT-ADDS-Tools'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]ADDS'
        }

        ADDomain 'ADDomain' {
            DomainName = $DomainName
            Credential = $AdminCreds
            SafeModeAdministratorPassword = $AdminCreds
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = @('[WindowsFeature]ADDS','[Disk]ADDataDisk')
        }
    }
}