param location string
param prefix string
param subnetId string

var bastionHostName = '${prefix}-bastionhost'

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${bastionHostName}-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastionHostName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableIpConnect: false
    enableTunneling: false
    disableCopyPaste: false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIpAddress.id
          }

        }
      }
    ]
    scaleUnits: 2
  }
}
