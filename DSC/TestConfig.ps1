Configuration TestConfig {

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'StorageDsc'

    LocalConfigurationManager {
        ActionAfterReboot  = 'ContinueConfiguration'
        ConfigurationMode  = 'ApplyOnly'
        RebootNodeIfNeeded = $true
    }

    WindowsFeature 'RSAT' {
        Name = 'RSAT-AD-PowerShell'
        Ensure = 'Present'
    }

    WaitForDisk Disk2 {
        DiskId = 2
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
    }

    Disk ADDataDis {
        DiskId = 2
        DriveLetter = "F"
        DependsOn = "[WaitForDisk]Disk2"
    }

    WindowsFeature 'DNS' {
        Name = 'DNS'
        Ensure = 'Present'
    }

    WindowsFeature 'ADDS' {
        Name = 'AD-Domain-Services'
        Ensure = 'Present'
        DependsOn = '[WindowsFeature]DNS'
    }
}