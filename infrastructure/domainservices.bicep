param location string = 'West Europe'
param artifactLocation string = 'https://github.com/balenr/PKI-Lab/raw/main/DSC/TestConfig.ps1.zip'
param vmName string

@description('The Active Directory domain name (e.g. contoso.com)')
param domainName string

@description('Administrator username for the domain')
param adminUsername string

@description('Administrator password for the domain')
@secure()
param adminPassword string

resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-12-01' existing = {
  name: vmName
}

resource windowsVMDsc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: virtualMachine
  name: '${virtualMachine.name}-DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: artifactLocation
      configurationFunction: 'TestConfig.ps1\\TestConfig'
      Properties: {
        DomainName: domainName
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        adminPassword: adminPassword
      }
    }
  }
}
