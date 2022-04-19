Configuration TestConfig {

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    LocalConfigurationManager {
        ActionAfterReboot  = 'ContinueConfiguration'
        ConfigurationMode  = 'ApplyOnly'
        RebootNodeIfNeeded = $true
    }

    WindowsFeature 'RSAT' {
        Name = 'RSAT-AD-PowerShell'
        Ensure = 'Present'
    }

    WindowsFeature 'DNS' {
        Name = 'DNS'
        Ensure = 'Present'
    }
}