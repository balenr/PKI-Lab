param location string = 'West Europe'
param artifactLocation string = 'https://github.com/balenr/PKI-Lab/raw/main/DSC/TestConfig.ps1.zip'

resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-12-01' existing = {
  name: 'whspki01'
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
    }
  }
}
