param name string
param location string
param vmSize string
param subnetId string
param offer string
param publisher string
param sku string
param version string
param adminUsername string
param ssh_public_key string
param storageAccountType string


resource vmnicdsvmlinux 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'dsvmlinux-nic'
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

resource vmdsvmlinux 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile:{
      vmSize: vmSize
    }
    osProfile:{
      adminUsername: adminUsername
      linuxConfiguration:{
        ssh:{
          publicKeys : [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: ssh_public_key
            }
          ]
        }
        disablePasswordAuthentication:true
      }
      computerName: 'dsvmlinux'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: vmnicdsvmlinux.id
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
