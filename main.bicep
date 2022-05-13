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
param deployBastion bool = false
param vnetSettings object = {
  addressPrefixes: [
    '10.10.0.0/16'
  ]
  subnets: [
    {
      name: 'subnet1'
      addressPrefix: '10.10.10.0/24'
      nsgDeploy: true
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '10.10.11.0/24'
      nsgDeploy: false
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

// Deploy Azure Bastion
module bastion 'infrastructure/bastion.bicep' = if (deployBastion) {
  name: 'deploy-bastion'
  params: {
    location: location
    prefix: prefix
    subnetId: '${network.outputs.vNetId}/subnets/AzureBastionSubnet'
  }
  dependsOn: [
    network
  ]
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
    addDataDisk: true
  }
  dependsOn: [
    network
  ]
}

module domainServicesDsc 'infrastructure/domainservices.bicep' = {
  name: 'ADDomainServicesDsc'
  params: {
    location: location
    vmName: domainController.outputs.virtualMachineName
    domainName: 'whsec.lab'
    adminUsername: '${prefix}admin'
    adminPassword: vmAdminPassword
  }
  dependsOn: [
    domainController
  ]
}
