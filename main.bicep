/*
WHS PKI Lab TODO:
  - Create resource group
  - Define virtual network(s)
  - Build PKI virtual machines
    - WHSPKI01: AD DC
    - WHSPKI02: CRL Web Enrollment
    - WHSPKI03: Standalone Root CA
    - WHSPKI04: Enterprise Subordinate CA
    - WHSPKI05: Windows 11 Client
*/

param location string
param prefix string
param vnetSettings object = {
  addressPrefixes: [
    '10.10.0.0/16'
  ]
  subnets: [
    {
      name: 'subnet1'
      addressPrefix: '10.10.10.0/24'
    }
  ]
}

@secure()
param vmAdminPassword string

// Deploy Network infrastructure
module network 'infrastructure/network.bicep' = {
  name: 'deploy-network'
  params: {
    location: location
    prefix: prefix
    vnetSettings: vnetSettings
  }
}

// Deploy domaincontroller
module domainController 'infrastructure/vm.bicep' = {
  name: 'deploy-dc'
  params: {
    location: location
    prefix: prefix
    subnetId: '${network.outputs.vNetId}/subnets/${vnetSettings.subnets[0].name}'
    vmSize: 'Standard_B2ms'
    adminPassword: vmAdminPassword
  }
  dependsOn: [
    network
  ]
}
