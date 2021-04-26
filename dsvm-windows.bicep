param name string
param location string
param vmSize string
param subnetId string
param offer string
param publisher string
param sku string
param version string
param adminUsername string
param vmpassword string
param storageAccountType string


resource vmnicdsvmwin 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'dsvmwin-nic'
  location: location
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties:{
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion:'IPv4'
        }
      }
    ]
  }
}

resource vmdsvmwin 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile:{
      vmSize: vmSize
    }
    osProfile:{
      adminUsername: adminUsername
      windowsConfiguration:{
        timeZone: 'Tokyo Standard Time'
      }
      adminPassword: vmpassword

      computerName: 'dsvmwin'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: vmnicdsvmwin.id
        }
      ]
    }
    storageProfile:{
      imageReference:{
        offer: offer
        publisher: publisher
        version: version
        sku: sku
      }
      osDisk:{
        createOption:'FromImage'
        managedDisk:{
          storageAccountType: storageAccountType
        }
      }
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled: true
      }
    }
  }
}
