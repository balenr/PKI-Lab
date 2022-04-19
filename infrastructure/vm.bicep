param location string
param prefix string
param subnetId string
param vmSize string
param adminUsername string = '${prefix}admin'
param addDataDisk bool = false

@secure()
param adminPassword string

var vmName = '${prefix}pki01'
var nicName = '${vmName}-nic'

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: addDataDisk ? [
        {
          name: '${vmName}_Data'
          createOption: 'Empty'
          lun: 0
          diskSizeGB: 16
          caching: 'None'
        }
      ] : json('null')
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  // Install the Azure Monitor Agent
  resource ama 'extensions@2021-11-01' = {
    name: 'AzureMonitorWindowsAgent'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: 'AzureMonitorWindowsAgent'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: true
    }
  }
}

output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
